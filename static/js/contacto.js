// -----------------------------------------------------------------------------
// Archivo: static/js/contacto.js
// Responsabilidad:
//   - Manejar la interacción del formulario de contacto.
//   - Simular el envío de la consulta mostrando un mensaje al usuario.
// Alcance:
//   - Se usa únicamente en la vista contacto.html.
// -----------------------------------------------------------------------------

document.addEventListener("DOMContentLoaded", function () {
  const form = document.getElementById("contactForm");
  const alertBox = document.getElementById("contactAlert");

  if (!form) return;

  form.addEventListener("submit", function (event) {
    event.preventDefault(); // Evitamos envío real

    const nombre = document.getElementById("nombre");
    const email = document.getElementById("email");
    const tipo = document.getElementById("tipo");
    const mensaje = document.getElementById("mensaje");

    // Validación simple en cliente
    if (
      !nombre.value.trim() ||
      !email.value.trim() ||
      !tipo.value ||
      !mensaje.value.trim()
    ) {
      mostrarAlerta(
        "Por favor, completá todos los campos obligatorios antes de enviar.",
        "error"
      );
      return;
    }

    // ✅ Simular envío correcto
    mostrarAlerta(
      "Su mensaje fue enviado exitosamente. Se le responderá dentro de las 72 hs.",
      "success"
    );

    // Limpiar formulario
    form.reset();
  });

  function mostrarAlerta(texto, tipo) {
    if (!alertBox) return;

    alertBox.textContent = texto;
    alertBox.style.display = "block";
    alertBox.classList.remove("contact-alert--error", "contact-alert--success");

    if (tipo === "error") {
      alertBox.classList.add("contact-alert--error");
    } else {
      alertBox.classList.add("contact-alert--success");
    }

    // Ocultar automáticamente después de unos segundos
    setTimeout(() => {
      alertBox.style.display = "none";
    }, 5000);
  }
});
