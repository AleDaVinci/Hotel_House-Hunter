// -----------------------------------------------
// Archivo: static/js/modificar_reserva.js
// Responsabilidad:
//   - Manejar la lógica de modificación de reservas desde la vista
//     "Mis reservas" sin recargar la página.
//   - Permitir sumar / restar días a la estadía, simulando el nuevo
//     total y validando disponibilidad.
//   - Aplicar el cambio de fechas si el usuario lo confirma.
//   - Cancelar la reserva actual para "cambiar totalmente" y
//     redirigir al dashboard para crear una nueva.
// Alcance:
//   - Se utiliza junto con mis_reservas.html
//   - Consume los endpoints del backend en modificar_reserva_routes.py
// -----------------------------------------------

/**
 * Parsea un string "YYYY-MM-DD" a objeto Date.
 */
function parseISODate(isoStr) {
  const [y, m, d] = isoStr.split("-").map(Number);
  return new Date(y, m - 1, d);
}

/**
 * Formatea un objeto Date a "YYYY-MM-DD" (para enviar al backend).
 */
function formatISODate(date) {
  const y = date.getFullYear();
  const m = String(date.getMonth() + 1).padStart(2, "0");
  const d = String(date.getDate()).padStart(2, "0");
  return `${y}-${m}-${d}`;
}

/**
 * Formatea un objeto Date a "DD/MM/YYYY" (para mostrar al usuario).
 */
function formatDisplayDate(date) {
  const d = String(date.getDate()).padStart(2, "0");
  const m = String(date.getMonth() + 1).padStart(2, "0");
  const y = date.getFullYear();
  return `${d}/${m}/${y}`;
}

/**
 * Formatea monto en ARS con 2 decimales.
 */
function formatMoneyARS(monto) {
  const num = Number(monto) || 0;
  return num.toLocaleString("es-AR", {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  });
}

/**
 * Obtiene el estado interno de edición de una card.
 * Si no existía, lo inicializa con deltaDias = 0.
 */
function getEditStateForCard(card) {
  if (!card._editState) {
    const fechaIniIso = card.dataset.fechaCheckIn;
    const fechaFinIso = card.dataset.fechaCheckOut;

    card._editState = {
      fechaCheckInOriginal: fechaIniIso,
      fechaCheckOutOriginal: fechaFinIso,
      deltaDias: 0, // cantidad de días extra (positiva o negativa)
    };
  }
  return card._editState;
}

/**
 * Calcula las nuevas fechas a partir del estado interno (mantiene
 * el check-in original y desplaza el check-out según deltaDias).
 */
function calcularNuevasFechas(card) {
  const state = getEditStateForCard(card);
  const fechaIni = parseISODate(state.fechaCheckInOriginal);
  const fechaOutOriginal = parseISODate(state.fechaCheckOutOriginal);

  const nuevaOut = new Date(fechaOutOriginal.getTime());
  nuevaOut.setDate(nuevaOut.getDate() + state.deltaDias);

  return {
    fechaCheckInIso: formatISODate(fechaIni),
    fechaCheckOutIso: formatISODate(nuevaOut),
    fechaCheckInDisplay: formatDisplayDate(fechaIni),
    fechaCheckOutDisplay: formatDisplayDate(nuevaOut),
  };
}

/**
 * Hace una llamada al backend para simular el cambio de fechas.
 */
async function simularCambioFechas(card) {
  const idReserva = card.dataset.reservaId;
  if (!idReserva) return;

  const editPanel = card.querySelector("[data-edit-panel]");
  if (!editPanel) return;

  const fechasNuevasEl = editPanel.querySelector(".edit-fechas-nuevas");
  const totalNuevoEl = editPanel.querySelector(".edit-total-nuevo");
  const diferenciaEl = editPanel.querySelector(".edit-diferencia");
  const mensajeEl = editPanel.querySelector("[data-edit-mensaje]");

  // Limpiamos mensajes previos
  if (mensajeEl) mensajeEl.textContent = "";
  if (totalNuevoEl) totalNuevoEl.textContent = "";
  if (diferenciaEl) diferenciaEl.textContent = "";
  if (fechasNuevasEl) fechasNuevasEl.textContent = "";

  const {
    fechaCheckInIso,
    fechaCheckOutIso,
    fechaCheckInDisplay,
    fechaCheckOutDisplay,
  } = calcularNuevasFechas(card);

  // Actualizamos texto de fechas nuevas (aunque falle luego la simulación)
  if (fechasNuevasEl) {
    fechasNuevasEl.textContent = `${fechaCheckInDisplay} → ${fechaCheckOutDisplay}`;
  }

  try {
    const resp = await fetch(`/reservas/${idReserva}/simular_cambio_fechas`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        fecha_check_in: fechaCheckInIso,
        fecha_check_out: fechaCheckOutIso,
      }),
    });

    const data = await resp.json().catch(() => null);

    if (!resp.ok || !data) {
      const msg =
        (data && data.message) ||
        "Ocurrió un error al simular el cambio de fechas.";
      if (mensajeEl) mensajeEl.textContent = msg;
      if (data && data.redirect) {
        window.location.href = data.redirect;
      }
      return;
    }

    if (data.ok === false) {
      const msg =
        data.message ||
        "No se pudo simular el cambio de fechas. Verificá los datos.";
      if (mensajeEl) mensajeEl.textContent = msg;
      if (data.redirect) {
        window.location.href = data.redirect;
      }
      return;
    }

    // Si no hay disponibilidad para estas nuevas fechas
    if (data.disponible === false) {
      if (mensajeEl) {
        mensajeEl.textContent =
          data.message ||
          "No hay disponibilidad para extender o modificar a estas fechas.";
      }
      return;
    }

    // Si todo OK: mostrar nuevo total y diferencia
    const nuevoTotal = data.nuevo_total ?? 0;
    const totalAnterior = data.total_anterior ?? 0;
    const diferencia = data.diferencia ?? nuevoTotal - totalAnterior;

    if (totalNuevoEl) {
      totalNuevoEl.textContent = `$ ${formatMoneyARS(nuevoTotal)}`;
    }

    if (diferenciaEl) {
      let signo = "";
      if (diferencia > 0) signo = "+";
      if (diferencia < 0) signo = "−";

      diferenciaEl.textContent = `${signo} $ ${formatMoneyARS(
        Math.abs(diferencia),
      )}`;
    }

    if (mensajeEl) {
      mensajeEl.textContent =
        "Las nuevas fechas son válidas y la habitación está disponible.";
    }
  } catch (error) {
    console.error("Error en simularCambioFechas:", error);
    if (mensajeEl) {
      mensajeEl.textContent =
        "Ocurrió un error de conexión al simular el cambio de fechas.";
    }
  }
}

/**
 * Aplica el cambio de fechas en el backend.
 */
async function aplicarCambioFechas(card) {
  const idReserva = card.dataset.reservaId;
  if (!idReserva) return;

  const editPanel = card.querySelector("[data-edit-panel]");
  if (!editPanel) return;
  const mensajeEl = editPanel.querySelector("[data-edit-mensaje]");

  const { fechaCheckInIso, fechaCheckOutIso } = calcularNuevasFechas(card);

  try {
    const resp = await fetch(`/reservas/${idReserva}/aplicar_cambio_fechas`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        fecha_check_in: fechaCheckInIso,
        fecha_check_out: fechaCheckOutIso,
      }),
    });

    const data = await resp.json().catch(() => null);

    if (!resp.ok || !data) {
      const msg =
        (data && data.message) ||
        "Ocurrió un error al guardar los cambios de la reserva.";
      if (mensajeEl) mensajeEl.textContent = msg;
      if (data && data.redirect) {
        window.location.href = data.redirect;
      }
      return;
    }

    if (data.ok === false) {
      const msg =
        data.message ||
        "No se pudo guardar el cambio de fechas. Verificá los datos.";
      if (mensajeEl) mensajeEl.textContent = msg;
      if (data.redirect) {
        window.location.href = data.redirect;
      }
      return;
    }

    // Si todo salió bien, recargamos o usamos redirect_url
    if (data.redirect_url) {
      window.location.href = data.redirect_url;
    } else {
      alert("La reserva fue modificada correctamente.");
      window.location.reload();
    }
  } catch (error) {
    console.error("Error en aplicarCambioFechas:", error);
    if (mensajeEl) {
      mensajeEl.textContent =
        "Ocurrió un error de conexión al guardar la modificación.";
    }
  }
}

/**
 * Cancela la reserva actual para que el usuario pueda generar una nueva.
 */
async function cambiarTotalmenteReserva(card) {
  const idReserva = card.dataset.reservaId;
  if (!idReserva) return;

  const confirmar = confirm(
    "Esto cancelará la reserva actual para que puedas crear una nueva.\n\n¿Deseas continuar?",
  );
  if (!confirmar) return;

  const editPanel = card.querySelector("[data-edit-panel]");
  const mensajeEl = editPanel
    ? editPanel.querySelector("[data-edit-mensaje]")
    : null;

  try {
    const resp = await fetch(
      `/reservas/${idReserva}/cambiar_totalmente`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
      },
    );

    const data = await resp.json().catch(() => null);

    if (!resp.ok || !data) {
      const msg =
        (data && data.message) ||
        "Ocurrió un error al cancelar la reserva.";
      if (mensajeEl) mensajeEl.textContent = msg;
      if (data && data.redirect) {
        window.location.href = data.redirect;
      }
      return;
    }

    if (data.ok === false) {
      const msg =
        data.message ||
        "No se pudo cancelar la reserva para cambiarla totalmente.";
      if (mensajeEl) mensajeEl.textContent = msg;
      if (data.redirect) {
        window.location.href = data.redirect;
      }
      return;
    }

    // Redirigimos al dashboard para que genere una nueva reserva
    if (data.redirect_url) {
      window.location.href = data.redirect_url;
    } else {
      alert("La reserva fue cancelada. Podés generar una nueva desde el inicio.");
      window.location.reload();
    }
  } catch (error) {
    console.error("Error en cambiarTotalmenteReserva:", error);
    if (mensajeEl) {
      mensajeEl.textContent =
        "Ocurrió un error de conexión al intentar cancelar la reserva.";
    }
  }
}

/**
 * Muestra u oculta el panel de edición dentro de una card.
 */
function toggleEditPanel(card, forceOpen = false) {
  const editPanel = card.querySelector("[data-edit-panel]");
  if (!editPanel) return;

  const isVisible =
    editPanel.style.display === "block" ||
    editPanel.classList.contains("reserva-card__edit--open");

  const shouldOpen = forceOpen ? true : !isVisible;

  if (shouldOpen) {
    // Cerramos otros paneles abiertos (opcional)
    document.querySelectorAll("[data-edit-panel]").forEach((panel) => {
      if (panel !== editPanel) {
        panel.style.display = "none";
        panel.classList.remove("reserva-card__edit--open");
      }
    });

    editPanel.style.display = "block";
    editPanel.classList.add("reserva-card__edit--open");

    // Inicializamos estado de edición y simulación inicial (delta 0)
    const state = getEditStateForCard(card);
    state.deltaDias = 0;
    simularCambioFechas(card);
  } else {
    editPanel.style.display = "none";
    editPanel.classList.remove("reserva-card__edit--open");
  }
}

/**
 * Suma o resta días en el estado interno y vuelve a simular.
 * direction = +1 (agregar día) o -1 (quitar día).
 */
function ajustarDias(card, direction) {
  const state = getEditStateForCard(card);

  // No permitir que la reserva quede con menos de 1 noche
  const fechaIni = parseISODate(state.fechaCheckInOriginal);
  const fechaOutOriginal = parseISODate(state.fechaCheckOutOriginal);

  const nochesOriginal =
    (fechaOutOriginal.getTime() - fechaIni.getTime()) /
    (1000 * 60 * 60 * 24);

  const nochesNuevas = nochesOriginal + state.deltaDias + direction;

  if (nochesNuevas < 1) {
    alert("La reserva debe tener al menos 1 noche.");
    return;
  }

  state.deltaDias += direction;
  simularCambioFechas(card);
}

document.addEventListener("DOMContentLoaded", () => {
  // Delegamos eventos de click en todo el documento
  document.body.addEventListener("click", (event) => {
    const btnModificar = event.target.closest(".js-abrir-modificar");
    const btnCerrar = event.target.closest(".js-cerrar-edicion");
    const btnSumar = event.target.closest(".js-modificar-sumar-dia");
    const btnRestar = event.target.closest(".js-modificar-restar-dia");
    const btnAplicar = event.target.closest(".js-aplicar-cambio-fechas");
    const btnCambiarTotalmente =
      event.target.closest(".js-cambiar-totalmente");

    // Si ninguno matchea, no hacemos nada
    if (
      !btnModificar &&
      !btnCerrar &&
      !btnSumar &&
      !btnRestar &&
      !btnAplicar &&
      !btnCambiarTotalmente
    ) {
      return;
    }

    const card = event.target.closest(".reserva-card");
    if (!card) return;

    // Abrir panel de modificación
    if (btnModificar) {
        toggleEditPanel(card);  // ← sin segundo parámetro
    return;
    }

    // Cerrar panel de modificación
    if (btnCerrar) {
      toggleEditPanel(card, false);
      return;
    }

    // Sumar/quitar días
    if (btnSumar) {
      ajustarDias(card, +1);
      return;
    }
    if (btnRestar) {
      ajustarDias(card, -1);
      return;
    }

    // Aplicar cambio de fechas
    if (btnAplicar) {
      aplicarCambioFechas(card);
      return;
    }

    // Cancelar y crear nueva
    if (btnCambiarTotalmente) {
      cambiarTotalmenteReserva(card);
      return;
    }
  });
});
