--  ---------------------------------------------------------------------------
--  GuiVerb (https://github.com/LionelDraghi/GuiVerb)
--  SPDX-License-Identifier: Apache-2.0
--  SPDX-FileCopyrightText: 2026, Lionel Draghi
--  ---------------------------------------------------------------------------

with Ada.IO_Exceptions;
with Ada.Strings.Fixed;
with Ada.Strings.Unbounded;
with GNAT.Sockets;

package body Guiverb_WebDriver is

   use Ada.Strings.Unbounded;
   use GNAT.Sockets;
   use Ada.IO_Exceptions;

   CRLF : constant String := ASCII.CR & ASCII.LF;

   --  Extract the value of Key in a flat or one-level JSON text.
   --  Returns the JSON token: quoted string (unescaped), true, false,
   --  or null. Minimal by design: the WebDriver responses used here
   --  are small and their shape is known.

   function Value_Of (JSON : String; Key : String) return String is
      Needle : constant String := """" & Key & """";
      Result : Unbounded_String;
   begin
      if JSON'Length < Needle'Length then
         return "";
      end if;
      for At_Key in JSON'First .. JSON'Last - Needle'Length + 1 loop
         if JSON (At_Key .. At_Key + Needle'Length - 1) = Needle then
            declare
               I : Natural := At_Key + Needle'Length;
            begin
               while I <= JSON'Last and then JSON (I) /= ':' loop
                  I := I + 1;
               end loop;
               I := I + 1;  --  past ':'
               while I <= JSON'Last and then JSON (I) = ' ' loop
                  I := I + 1;
               end loop;
               if I > JSON'Last then
                  return "";
               end if;
               if JSON (I) = '"' then  --  quoted string
                  I := I + 1;
                  while I <= JSON'Last loop
                     if JSON (I) = '\' and then I < JSON'Last then
                        I := I + 1;
                        case JSON (I) is
                           when 'n' => Append (Result, ASCII.LF);
                           when 't' => Append (Result, ASCII.HT);
                           when others => Append (Result, JSON (I));
                        end case;
                     elsif JSON (I) = '"' then
                        return To_String (Result);
                     else
                        Append (Result, JSON (I));
                     end if;
                     I := I + 1;
                  end loop;
                  return To_String (Result);
               else  --  bare token: true, false, null, number
                  while I <= JSON'Last
                    and then JSON (I) not in ',' | '}' | ']' | ASCII.LF
                  loop
                     Append (Result, JSON (I));
                     I := I + 1;
                  end loop;
                  return To_String (Result);
               end if;
            end;
         end if;
      end loop;
      return "";
   end Value_Of;

   --  Read one CRLF-terminated header line.

   function Read_Line (Channel : Stream_Access) return String is
      C      : Character;
      Result : Unbounded_String;
   begin
      loop
         Character'Read (Channel, C);
         exit when C = ASCII.LF;
         if C /= ASCII.CR then
            Append (Result, C);
         end if;
      end loop;
      return To_String (Result);
   end Read_Line;

   --  One HTTP request, one response. The driver does not necessarily
   --  close the connection, so we do not wait for EOF: headers are
   --  read until the empty line, then exactly Content_Length bytes of
   --  body. The receive timeout bounds a stalled connection.

   procedure Call
     (Method    :     String;
      Path      :     String;
      Body_Text :     String;
      Status    : out Natural;
      Response  : out Unbounded_String)
   is
      Socket          : Socket_Type;
      Channel         : Stream_Access;
      Request         : constant String :=
        Method & " " & Path & " HTTP/1.1" & CRLF
        & "Host: localhost" & CRLF
        & "Content-Type: application/json; charset=utf-8" & CRLF
        & "Content-Length:" & Integer'Image (Body_Text'Length) & CRLF
        & "Connection: close" & CRLF
        & CRLF
        & Body_Text;
      Content_Length  : Natural := 0;
      C               : Character;
   begin
      Status := 0;
      Create_Socket (Socket);
      Set_Socket_Option (Socket, Socket_Level, (Receive_Timeout, 10.0));
      Connect_Socket
        (Socket,
         Sock_Addr_Type'(Family => Family_Inet,
                         Addr   => Inet_Addr ("127.0.0.1"),
                         Port   => Driver_Port));
      Channel := Stream (Socket);
      String'Write (Channel, Request);

      declare
         Line : constant String := Read_Line (Channel);
      begin
         --  status line: "HTTP/1.1 200 OK"
         if Line'Length > 12
           and then Line (Line'First .. Line'First + 4) = "HTTP/"
           and then Line (Line'First + 5) = '1'
         then
            declare
               First : constant Natural := Line'First + 5;
               Space : Natural := First;
            begin
               while Space <= Line'Last
                 and then Line (Space) /= ' '
               loop
                  Space := Space + 1;
               end loop;
               if Space < Line'Last then
                  Status := Natural'Value
                    (Line (Space + 1 .. Space + 3));
               end if;
            end;
         end if;
      end;

      loop
         --  headers, until the empty line
         declare
            Line : constant String := Read_Line (Channel);
            Key  : constant String := "Content-Length:";
         begin
            exit when Line = "";
            if Line'Length > Key'Length
              and then Line (Line'First .. Line'First + Key'Length - 1) = Key
            then
               Content_Length := Natural'Value
                 (Ada.Strings.Fixed.Trim
                    (Line (Line'First + Key'Length .. Line'Last),
                     Ada.Strings.Left));
            end if;
         end;
      end loop;

      for I in 1 .. Content_Length loop
         Character'Read (Channel, C);
         Append (Response, C);
      end loop;

      Close_Socket (Socket);
   exception
      when End_Error | Socket_Error =>
         Close_Socket (Socket);
   end Call;

   procedure HTTP
     (Method    :     String;
      Path      :     String;
      Body_Text :     String;
      Status    : out Natural;
      Response  : out Unbounded_String)
   is
   begin
      Call (Method, Path, Body_Text, Status, Response);
   exception
      when others =>
         raise Driver_Unreachable
         with "no answer from the web driver on port"
              & Driver_Port'Image;
   end HTTP;

   function Ready return Boolean is
      Status   : Natural;
      Response : Unbounded_String;
   begin
      HTTP ("GET", "/status", "", Status, Response);
      return Status = 200
        and then Value_Of (To_String (Response), "ready") = "true";
   exception
      when Driver_Unreachable =>
         return False;
   end Ready;

   function Session_Body (Headed : Boolean) return String is
      Browser_Args : constant String :=
        (if Headed
         then """--no-sandbox"",""--disable-gpu"""
         else """--headless=new"",""--no-sandbox"",""--disable-gpu""");
   begin
      return "{""capabilities"":{""alwaysMatch"":{"
        & """browserName"":""chrome"","
        & """goog:chromeOptions"":{""args"":[" & Browser_Args & "]}}}}";
   end Session_Body;

   function New_Session (Headed : Boolean := False) return String is
      Status   : Natural;
      Response : Unbounded_String;
   begin
      HTTP ("POST", "/session", Session_Body (Headed), Status, Response);
      declare
         Id : constant String :=
           Value_Of (To_String (Response), "sessionId");
      begin
         if Status not in 200 | 201 or else Id = "" then
            raise Request_Failed
            with "session creation failed (status"
                 & Status'Image & ")";
         end if;
         return Id;
      end;
   end New_Session;

   procedure Navigate (Session_Id : String; URL : String) is
      Status   : Natural;
      Response : Unbounded_String;
      Body_Text : constant String := "{""url"":""" & URL & """}";
   begin
      HTTP ("POST", "/session/" & Session_Id & "/url", Body_Text,
            Status, Response);
      if Status not in 200 | 201 then
         raise Request_Failed
         with "navigation to " & URL & " failed (status"
              & Status'Image & ")";
      end if;
   end Navigate;

   function Title (Session_Id : String) return String is
      Status   : Natural;
      Response : Unbounded_String;
   begin
      HTTP ("GET", "/session/" & Session_Id & "/title", "",
            Status, Response);
      if Status not in 200 | 201 then
         raise Request_Failed
         with "window title retrieval failed (status"
              & Status'Image & ")";
      end if;
      return Value_Of (To_String (Response), "value");
   end Title;

   procedure Delete_Session (Session_Id : String) is
      Status   : Natural;
      Response : Unbounded_String;
   begin
      HTTP ("DELETE", "/session/" & Session_Id, "", Status, Response);
   end Delete_Session;

end Guiverb_WebDriver;
