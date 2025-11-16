// -----------------------------------------------
// Archivo: static/js/mis_reservas.js
// Responsabilidad:
//   - Manejar interacciones de la vista "Mis reservas":
//       * Expandir / colapsar el detalle de cada reserva
//         dentro de su propia card.
// Alcance:
//   - Solo se usa en la plantilla mis_reservas.html
//   - No realiza llamadas al backend, solo maneja UI.
// -----------------------------------------------

document.addEventListener("DOMContentLoaded", () => {
  // Delegamos el manejo de clicks en todo el documento
  document.body.addEventListener("click", (event) => {
    const btnDetalle = event.target.closest(".js-ver-detalle");
    if (!btnDetalle) return;

    // Encontrar la card de la reserva más cercana
    const card = btnDetalle.closest(".reserva-card");
    if (!card) return;

    // Buscar el bloque de detalles dentro de esa card
    const details = card.querySelector(".reserva-card__details");
    if (!details) return;

    // Alternar clase para mostrar / ocultar
    const isOpen = details.classList.toggle("reserva-card__details--open");

    // Actualizar el texto del botón según el estado
    btnDetalle.textContent = isOpen ? "Ocultar detalle" : "Ver detalle";
  });
});
