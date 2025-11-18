// -----------------------------------------------
// Archivo: static/js/filtros_reservas.js
// Responsabilidad:
//   - Manejar los filtros y el orden de las reservas
//     en la vista "Mis reservas".
//       * Ordenar por fecha de check-in o por monto total.
//       * Filtrar por estado (todas, confirmada, pendiente,
//         cancelada, finalizada).
// Alcance:
//   - Solo se usa en mis_reservas.html
//   - No hace llamadas al backend, solo manipula el DOM.
// -----------------------------------------------

document.addEventListener("DOMContentLoaded", () => {
  const selectOrden = document.getElementById("orden-reservas");
  const selectEstado = document.getElementById("filtro-estado");
  const grid = document.querySelector(".misreservas-grid");

  // Si no hay reservas (o no existe el grid), no hacemos nada
  if (!selectOrden || !selectEstado || !grid) {
    return;
  }

  // Todas las cards actuales (NUCLEO de datos en memoria)
  const cards = Array.from(grid.querySelectorAll(".reserva-card"));

  /**
   * Aplica el filtro por estado y el orden seleccionado,
   * reordenando las cards en el DOM.
   */
  function aplicarFiltrosYOrden() {
    const criterioOrden = selectOrden.value;     // checkin_asc, checkin_desc, monto_asc, monto_desc
    const filtroEstado = selectEstado.value;     // todos, confirmada, pendiente, ...

    // 1) Filtrar por estado
    const visibles = cards.filter((card) => {
      const estado = (card.dataset.estado || "").toLowerCase();

      if (filtroEstado === "todos") return true;

      return estado === filtroEstado.toLowerCase();
    });

    // 2) Ordenar según criterio
    visibles.sort((a, b) => {
      switch (criterioOrden) {
        case "checkin_asc":
        case "checkin_desc": {
          const da = a.dataset.fechaCheckIn; // "YYYY-MM-DD"
          const db = b.dataset.fechaCheckIn;

          if (!da || !db) return 0;

          // Como están en formato ISO (YYYY-MM-DD), se pueden comparar como string
          let res = 0;
          if (da < db) res = -1;
          else if (da > db) res = 1;

          return criterioOrden === "checkin_asc" ? res : -res;
        }

        case "monto_asc":
        case "monto_desc": {
          const ma = parseFloat(a.dataset.montoTotal || "0");
          const mb = parseFloat(b.dataset.montoTotal || "0");

          const res = ma - mb;
          return criterioOrden === "monto_asc" ? res : -res;
        }

        default:
          return 0;
      }
    });

    // 3) Ocultamos todas para empezar desde cero
    cards.forEach((card) => {
      card.style.display = "none";
    });

    // 4) Mostramos y reinsertamos solo las visibles, ya ordenadas
    visibles.forEach((card) => {
      card.style.display = "";
      grid.appendChild(card); // esto cambia el orden visual
    });
  }

  // Listeners para cuando el usuario cambia algo
  selectOrden.addEventListener("change", aplicarFiltrosYOrden);
  selectEstado.addEventListener("change", aplicarFiltrosYOrden);

  // Aplicar una vez al cargar (por si queremos un orden inicial coherente)
  aplicarFiltrosYOrden();
});
