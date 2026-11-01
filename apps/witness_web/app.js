// -----------------------------------------------------------------------------
// GuiVerb (https://github.com/LionelDraghi/GuiVerb)
// SPDX-License-Identifier: Apache-2.0
// SPDX-FileCopyrightText: 2026, Lionel Draghi
// -----------------------------------------------------------------------------

// GuiVerb witness application — no framework, ARIA carries the semantics.

const dialog = document.getElementById('login-dialog');
const continueButton = document.getElementById('continue');
const refreshButton = document.getElementById('refresh');
const statusLine = document.getElementById('status');
const userField = document.getElementById('user');
const loginAlert = document.getElementById('login-alert');

continueButton.addEventListener('click', () => {
  loginAlert.hidden = true;
  userField.value = '';
  dialog.showModal();
  userField.focus();
});

refreshButton.addEventListener('click', () => {
  statusLine.hidden = true;
  // The refresh is asynchronous on purpose: the scenario waits for it.
  setTimeout(() => {
    statusLine.textContent = 'Up to date';
    statusLine.hidden = false;
  }, 300);
});

document.getElementById('login-form').addEventListener('submit', (event) => {
  if (userField.value === '') {
    event.preventDefault();
    loginAlert.hidden = false;
    userField.focus();
  }
});
