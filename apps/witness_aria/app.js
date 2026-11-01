//  ARIA practices witness: disclosure pattern (Authoring Practices).
//  The button toggles aria-expanded and the visibility of the region
//  it controls; no other framework, no other dependency.

const toggle = document.getElementById('details-toggle');
const details = document.getElementById('details');

toggle.addEventListener('click', () => {
  const open = toggle.getAttribute('aria-expanded') === 'true';
  toggle.setAttribute('aria-expanded', String(!open));
  details.hidden = open;
});
