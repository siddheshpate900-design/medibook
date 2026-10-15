/* =====================================================================
   MediBook - app.js
   Three small jobs, nothing else:
     1. the booking filter form reloads itself when a box is changed
     2. a destructive button asks before it sends the form
     3. the password box shows whether the rules are met
   No animation, no scroll effect, no library. The site works without this
   file too, because every step has a normal button.
   ===================================================================== */
(function () {
  'use strict';

  /* 1. booking filter ------------------------------------------------ */
  document.querySelectorAll('select[data-autosubmit]').forEach(function (box) {
    box.addEventListener('change', function () {
      var form = box.closest('form');
      if (form) { form.submit(); }
    });
  });

  /* 2. confirm before a destructive submit --------------------------- */
  document.querySelectorAll('form[data-confirm]').forEach(function (form) {
    form.addEventListener('submit', function (event) {
      if (!window.confirm(form.getAttribute('data-confirm'))) {
        event.preventDefault();
      }
    });
  });

  /* 3. password rule counter ---------------------------------------- */
  function score(value) {
    var points = 0;
    if (value.length >= 8) { points += 1; }
    if (/[A-Za-z]/.test(value) && /[0-9]/.test(value)) { points += 1; }
    if (value.length >= 12 || /[^A-Za-z0-9]/.test(value)) { points += 1; }
    return points;
  }

  document.querySelectorAll('input[data-strength]').forEach(function (input) {
    var meter = document.getElementById(input.getAttribute('data-strength'));
    if (!meter) { return; }
    input.addEventListener('input', function () {
      var points = score(input.value);
      meter.className = input.value.length === 0 ? 'pw-meter' : 'pw-meter is-' + points;
    });
  });
}());
