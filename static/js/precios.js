// -----------------------------------------------
// Archivo: static/js/precios.js
// Responsabilidad:
// - Renderizar las habitaciones en la pestaña "Habitaciones"
//   con sus tarifas, promociones y precios finales.
// - Manejar el cambio de tarifa seleccionada y actualizar
//   el "Total seleccionado" en cada card.
// - Disparar la creación real de una reserva en el backend
//   cuando el usuario presiona "Reservar".
// -----------------------------------------------

/**
 * Formatea un número como moneda ARS con 2 decimales.
 */
function formatMoneyARS(monto) {
  return monto.toLocaleString("es-AR", {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  });
}

/**
 * Construye el HTML de las amenidades de una habitación.
 */
function construirAmenidadesHtml(habitacion) {
  const amenidades = habitacion.amenidades || [];
  if (!amenidades.length) return "";

  return amenidades
    .map(
      (am) => `
        <img src="${am.icono}"
             alt="${am.nombre}"
             title="${am.nombre}"
             class="amenidad-icon">
      `,
    )
    .join("");
}

/**
 * Construye el HTML de las opciones de tarifa de una habitación.
 * Usa la clave "tarifas" que viene desde el backend.
 */
function construirTarifasHtml(habitacion, noches) {
  const tarifas = habitacion.tarifas || [];
  if (!tarifas.length) {
    return `<p class="tarifa-option__sin-tarifa">No hay tarifas disponibles.</p>`;
  }

  return tarifas
    .map((t, index) => {
      const promo = t.promo_aplicada;
      const idRadio = `tarifa_${habitacion.id_habitacion}_${t.id_tarifa}`;

      // Precio total base (sin promo) y final (con promo si aplica)
      const totalBase = t.total_base ?? t.monto_noche * noches;
      const totalFinal = t.total_final ?? t.precio_noche_final * noches;

      let preciosHtml = "";

      if (promo) {
        preciosHtml = `
          <div class="tarifa-option__precios">
            <span class="tarifa-option__base">
              ARS ${formatMoneyARS(totalBase)}
            </span>
            <span class="tarifa-option__final">
              ARS ${formatMoneyARS(totalFinal)}
            </span>
            <span class="tarifa-option__badge">
              -${promo.porcentaje_descuento}% ${promo.nombre}
            </span>
          </div>
        `;
      } else {
        preciosHtml = `
          <div class="tarifa-option__precios">
            <span class="tarifa-option__final">
              ARS ${formatMoneyARS(totalFinal)}
            </span>
          </div>
        `;
      }

      // data-id-promocion: si hay promo, mandamos su id; si no, vacío/null
      const idPromocionAttr = promo && promo.id_promocion ? promo.id_promocion : "";

      return `
      <label class="tarifa-option">
        <input type="radio"
               id="${idRadio}"
               name="tarifa_${habitacion.id_habitacion}"
               value="${t.id_tarifa}"
               data-total-final="${totalFinal}"
               data-id-promocion="${idPromocionAttr}"
               ${index === 0 ? "checked" : ""}>

        <div class="tarifa-option__info">
          <div class="tarifa-option__header">
            <span class="tarifa-option__nombre">
              ${t.nombre}
              ${t.es_reembolsable ? "(Reembolsable)" : "(No reembolsable)"}
            </span>
          </div>
          ${preciosHtml}
        </div>
      </label>
      `;
    })
    .join("");
}

/**
 * Conecta los radios de tarifa de cada habitación con el
 * texto "Total seleccionado: ARS X" y el botón Reservar.
 */
function inicializarEventosTarifas(contenedorHabitaciones, noches) {
  const cards = contenedorHabitaciones.querySelectorAll(".habitacion-card");

  cards.forEach((card) => {
    const radios = card.querySelectorAll(
      "input[type='radio'][name^='tarifa_']",
    );
    const totalLabel = card.querySelector(".habitacion-total");
    const nochesLabel = card.querySelector(".habitacion-total-noches");
    const btnReservar = card.querySelector(".habitacion-btn-reservar");
    const idHabitacion = card.dataset.idHabitacion;

    if (nochesLabel) {
      nochesLabel.textContent = `${noches} noches`;
    }

    if (!radios.length || !totalLabel) return;

    function actualizarTotal() {
      const seleccionado = Array.from(radios).find((r) => r.checked);
      if (!seleccionado) return;

      const total = parseFloat(seleccionado.dataset.totalFinal || "0");
      totalLabel.textContent = `ARS ${formatMoneyARS(total)}`;
    }

    radios.forEach((r) => r.addEventListener("change", actualizarTotal));
    actualizarTotal(); // inicial

    if (btnReservar) {
      btnReservar.addEventListener("click", async () => {
        const seleccionado = Array.from(radios).find((r) => r.checked);
        if (!seleccionado) {
          alert("Por favor, seleccioná una tarifa.");
          return;
        }

        const idTarifa = seleccionado.value;
        const total = parseFloat(seleccionado.dataset.totalFinal || "0");
        const idPromocion = seleccionado.dataset.idPromocion || null;

        // Tomamos las fechas y cantidad de huéspedes del formulario
        const inputFechaInicio = document.getElementById("fecha_inicio");
        const inputFechaFin = document.getElementById("fecha_fin");
        const inputPasajeros = document.getElementById("pasajeros");

        const fechaCheckIn = inputFechaInicio ? inputFechaInicio.value : null;
        const fechaCheckOut = inputFechaFin ? inputFechaFin.value : null;
        const cantidadHuespedes = inputPasajeros
          ? inputPasajeros.value
          : null;

        if (!fechaCheckIn || !fechaCheckOut || !cantidadHuespedes) {
          alert(
            "Faltan datos de la búsqueda (fechas o pasajeros). Volvé a realizar la búsqueda.",
          );
          return;
        }

        // Armamos el payload para el backend
        const payload = {
          id_habitacion: idHabitacion,
          id_tarifa: idTarifa,
          id_promocion: idPromocion || null,
          fecha_check_in: fechaCheckIn,
          fecha_check_out: fechaCheckOut,
          cantidad_huespedes: cantidadHuespedes,
          noches: noches,
          monto_total: total,
        };

        try {
          const resp = await fetch("/reservas/crear", {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
            },
            body: JSON.stringify(payload),
          });

          const data = await resp.json().catch(() => null);

          if (!resp.ok || !data || data.ok === false) {
            const msg =
              (data && data.message) ||
              "Ocurrió un error al crear la reserva. Intentá nuevamente.";
            alert(msg);
            // Si el backend envía redirect (por ejemplo a login), lo usamos
            if (data && data.redirect) {
              window.location.href = data.redirect;
            }
            return;
          }

          // Si todo salió bien, redirigimos a Mis Reservas
          if (data.redirect_url) {
            window.location.href = data.redirect_url;
          } else {
            // fallback: recargar página o mostrar mensaje
            alert("Reserva creada correctamente.");
            window.location.reload();
          }
        } catch (error) {
          console.error("Error al crear la reserva:", error);
          alert(
            "Ocurrió un error de conexión al crear la reserva. Intentá nuevamente.",
          );
        }
      });
    }
  });
}

/**
 * Función global para renderizar las habitaciones con precios en el
 * contenedor que le pasemos. Se llama desde dashboard.js.
 *
 * @param {Object} data - Objeto JSON devuelto por /buscar_habitaciones
 * @param {HTMLElement} contHabitaciones - Contenedor del tab "Habitaciones"
 */
function renderHabitacionesConPrecios(data, contHabitaciones) {
  contHabitaciones.innerHTML = "";

  if (!data.ok) {
    const msg =
      data.message ||
      "Ocurrió un error al buscar habitaciones. Intenta nuevamente.";
    contHabitaciones.innerHTML = `<p>${msg}</p>`;
    return;
  }

  const habitaciones = data.habitaciones || [];
  const noches = data.noches || 1;

  if (!habitaciones.length) {
    contHabitaciones.innerHTML =
      "<p>No hay disponibilidad para los criterios seleccionados.</p>";
    return;
  }

  habitaciones.forEach((h) => {
    const amenidadesHtml = construirAmenidadesHtml(h);
    const tarifasHtml = construirTarifasHtml(h, noches);

    const cardHtml = `
      <article class="habitacion-card" data-id-habitacion="${h.id_habitacion}">
        <img src="/static/img/${h.imagen}"
             class="habitacion-card__img"
             alt="Habitación ${h.nombre}">
        
        <div class="habitacion-card__body">
          <!-- Columna izquierda: info + amenidades -->
          <div class="habitacion-card__info">
            <h3>${h.nombre}</h3>
            <p>${h.descripcion}</p>
            <p><strong>Capacidad:</strong> ${h.capacidad}</p>

            <div class="habitacion-amenidades">
              ${amenidadesHtml}
            </div>
          </div>

          <!-- Columna derecha: tarifas + total + botón -->
          <div class="habitacion-card__pricing">
            <div class="habitacion-card__tarifas">
              ${tarifasHtml}
            </div>

            <div class="habitacion-card__total">
              <div class="habitacion-card__total-line">
                Total seleccionado
                <span class="habitacion-total-noches"></span>:
                <strong class="habitacion-total"></strong>
              </div>
              <button type="button"
                      class="btn btn--primary habitacion-btn-reservar">
                Reservar
              </button>
            </div>
          </div>
        </div>
      </article>
    `;

    contHabitaciones.insertAdjacentHTML("beforeend", cardHtml);
  });

  // Conectar radios, totales, noches y botón Reservar
  inicializarEventosTarifas(contHabitaciones, noches);
}

// Hacemos visible la función en el scope global para que
// dashboard.js pueda llamarla.
window.renderHabitacionesConPrecios = renderHabitacionesConPrecios;
