// -------------------------------------------------------------------------
// Archivo: static/js/signup.js
// Responsabilidad:
//   - Validar el formulario de registro en el lado del cliente.
//   - Mejorar UX: mostrar/ocultar contraseña, validar coincidencia.
// Alcance:
//   - Se usa únicamente en la vista signup.html.
// -------------------------------------------------------------------------

document.addEventListener("DOMContentLoaded", function () {
  const form = document.getElementById("signupForm");
  const passwordInput = document.getElementById("password");
  const passwordConfirmInput = document.getElementById("password_confirm");
  const passwordError = document.getElementById("passwordError");

  // Mostrar / ocultar contraseñas
  const eyeButtons = document.querySelectorAll(".btn-eye");
  eyeButtons.forEach((btn) => {
    btn.addEventListener("click", function () {
      const targetSelector = btn.getAttribute("data-target");
      const input = document.querySelector(targetSelector);

      if (!input) return;

      if (input.type === "password") {
        input.type = "text";
      } else {
        input.type = "password";
      }
    });
  });

  // Validación de contraseñas iguales
  function checkPasswords() {
    if (!passwordInput.value || !passwordConfirmInput.value) {
      passwordError.style.display = "none";
      return true;
    }

    if (passwordInput.value !== passwordConfirmInput.value) {
      passwordError.style.display = "block";
      return false;
    } else {
      passwordError.style.display = "none";
      return true;
    }
  }

  passwordInput.addEventListener("input", checkPasswords);
  passwordConfirmInput.addEventListener("input", checkPasswords);

  // Validar antes de enviar
  form.addEventListener("submit", function (event) {
    const ok = checkPasswords();
    if (!ok) {
      event.preventDefault();
      passwordConfirmInput.focus();
    }
  });
});
