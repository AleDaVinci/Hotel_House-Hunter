// -----------------------------------------------
// Archivo: static/js/mis_reservas.js
// Responsabilidad:
//   - Manejar interacciones de la vista "Mis reservas":
//       * Expandir / colapsar el detalle de cada reserva
//         dentro de su propia card.
//       * Mostrar / ocultar el cuadro contextual con
//         las condiciones de pago al hacer click en
//         el estado de pago ("Pago: Impago").
// Alcance:
//   - Solo se usa en la plantilla mis_reservas.html
//   - No realiza llamadas al backend, solo maneja UI.
// -----------------------------------------------

document.addEventListener("DOMContentLoaded", () => {
  document.body.addEventListener("click", (event) => {
    // ============================
    // 1) Ver / ocultar detalle
    // ============================
    const btnDetalle = event.target.closest(".js-ver-detalle");
    if (btnDetalle) {
      const card = btnDetalle.closest(".reserva-card");
      if (!card) return;

      const details = card.querySelector(".reserva-card__details");
      if (!details) return;

      const isOpen = details.classList.toggle("reserva-card__details--open");
      btnDetalle.textContent = isOpen ? "Ocultar detalle" : "Ver detalle";
      // No hacemos return porque el mismo click podría impactar
      // otros comportamientos en el futuro.
    }

    // ======================================
    // 2) Toggle del popover de condiciones
    //    de pago (Pago: Impago)
    // ======================================
    const btnPago = event.target.closest(".js-estado-pago");
    if (btnPago) {
      const card = btnPago.closest(".reserva-card");
      if (!card) return;

      const panel = card.querySelector("[data-payment-info]");
      if (!panel) return;

      const estabaAbierto = panel.classList.contains(
        "reserva-card__payment-info--open"
      );

      // Cerrar cualquier otro popover abierto
      document
        .querySelectorAll(".reserva-card__payment-info--open")
        .forEach((el) => {
          el.classList.remove("reserva-card__payment-info--open");
        });

      // Si no estaba abierto, abrir este
      if (!estabaAbierto) {
        panel.classList.add("reserva-card__payment-info--open");
      }

      // Importante: como el click viene del propio botón,
      // no continuamos con la lógica de "click fuera".
      return;
    }

    // ======================================
    // 3) Cerrar popover al hacer click fuera
    // ======================================
    const clickDentroPopover = event.target.closest(".reserva-card__payment-info");
    if (!clickDentroPopover) {
      document
        .querySelectorAll(".reserva-card__payment-info--open")
        .forEach((el) => {
          el.classList.remove("reserva-card__payment-info--open");
        });
    }
  });
});
