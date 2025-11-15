// -----------------------------------------------
// Archivo: static/js/dashboard.js
// Responsabilidad:
// - Manejar tabs dinámicos del dashboard
// - Controlar y validar fechas del formulario de búsqueda
// - Validar formulario de búsqueda (campos obligatorios)
// - Enviar búsqueda al backend vía fetch (AJAX)
// - Renderizar habitaciones en la pestaña "Habitaciones"
// -----------------------------------------------

document.addEventListener("DOMContentLoaded", () => {
  // ====== ELEMENTOS COMUNES ======
  const buttons = document.querySelectorAll(".tab-btn");
  const tabs = document.querySelectorAll(".tab-content");
  const form = document.getElementById("buscarForm");
  const fechaInicio = document.getElementById("fecha_inicio");
  const fechaFin = document.getElementById("fecha_fin");
  const pasajeros = document.getElementById("pasajeros");
  const contHabitaciones = document.getElementById("tab-habitaciones");

  // Si por algún motivo no está el formulario, no seguimos
  if (!form || !fechaInicio || !fechaFin || !pasajeros || !contHabitaciones) {
    console.warn("⚠️ No se encontraron todos los elementos del dashboard.");
    return;
  }

  // ====== CONTROL DE FECHAS (MIN = HOY, SALIDA >= ENTRADA) ======

  // Obtenemos la fecha de hoy en formato YYYY-MM-DD
  const hoy = new Date();
  hoy.setHours(0, 0, 0, 0); // normalizamos hora
  const hoyStr = hoy.toISOString().split("T")[0];

  // No permitir fechas anteriores a hoy
  fechaInicio.min = hoyStr;
  fechaFin.min = hoyStr;

  // Cuando cambia la fecha de entrada:
  fechaInicio.addEventListener("change", () => {
    if (!fechaInicio.value) return;

    // Si el usuario elige una fecha de entrada menor a hoy, corregimos
    if (fechaInicio.value < hoyStr) {
      alert("La fecha de entrada no puede ser anterior a hoy.");
      fechaInicio.value = hoyStr;
    }

    // La fecha de salida no puede ser menor a la de entrada
    fechaFin.min = fechaInicio.value;

    if (fechaFin.value && fechaFin.value < fechaInicio.value) {
      fechaFin.value = fechaInicio.value;
    }
  });

  // Cuando cambia la fecha de salida:
  fechaFin.addEventListener("change", () => {
    if (!fechaFin.value) return;

    // No permitir fechas de salida en el pasado
    if (fechaFin.value < hoyStr) {
      alert("La fecha de salida no puede ser anterior a hoy.");
      fechaFin.value = hoyStr;
      return;
    }

    // Si hay fecha de entrada, validamos el orden
    if (fechaInicio.value && fechaFin.value < fechaInicio.value) {
      alert("La fecha de salida no puede ser anterior a la fecha de entrada.");
      fechaFin.value = fechaInicio.value;
    }
  });

  // ====== FUNCIONES AUXILIARES ======

  function activarTab(target) {
    // Quitar activo de todos los botones
    buttons.forEach((b) => b.classList.remove("active"));

    // Activar el botón cuyo data-target coincide
    const botonTarget = document.querySelector(
      `[data-target="${target}"]`
    );
    if (botonTarget) {
      botonTarget.classList.add("active");
    }

    // Ocultar todas las tabs
    tabs.forEach((tab) => tab.classList.remove("active"));

    // Mostrar la tab objetivo
    const tabTarget = document.getElementById(target);
    if (tabTarget) {
      tabTarget.classList.add("active");
    }
  }

  function validarCamposBusqueda() {
    let valido = true;

    // Limpiar errores visuales
    [fechaInicio, fechaFin, pasajeros].forEach((campo) => {
      campo.classList.remove("campo-error");
    });

    // 1) Validar que no estén vacíos
    [fechaInicio, fechaFin, pasajeros].forEach((campo) => {
      if (!campo.value || campo.value.trim() === "") {
        campo.classList.add("campo-error");
        valido = false;
      }
    });

    if (!valido) {
      alert("Por favor, completá todos los campos de búsqueda.");
      return false;
    }

    // 2) Validar que las fechas no sean anteriores a hoy
    if (fechaInicio.value < hoyStr) {
      fechaInicio.classList.add("campo-error");
      alert("La fecha de entrada no puede ser anterior a hoy.");
      valido = false;
    }

    if (fechaFin.value < hoyStr) {
      fechaFin.classList.add("campo-error");
      alert("La fecha de salida no puede ser anterior a hoy.");
      valido = false;
    }

    // 3) Validar que fecha_fin >= fecha_inicio
    if (fechaInicio.value && fechaFin.value && fechaFin.value < fechaInicio.value) {
      fechaFin.classList.add("campo-error");
      alert("La fecha de salida no puede ser anterior a la fecha de entrada.");
      valido = false;
    }

    return valido;
  }

  // ====== CLIC EN LOS BOTONES DE TAB ======
  buttons.forEach((btn) => {
    btn.addEventListener("click", () => {
      const target = btn.dataset.target;

      // Si el usuario clickea la pestaña Habitaciones,
      // primero exigimos que haya hecho una búsqueda válida.
      if (target === "tab-habitaciones") {
        const valido = validarCamposBusqueda();
        if (!valido) {
          // opcional: scrollear hacia el formulario
          form.scrollIntoView({ behavior: "smooth", block: "center" });
          return; // no cambiamos de pestaña
        }

        // Si los campos están completos y válidos, disparamos la búsqueda
        // como si hubiera apretado el botón "Buscar".
        form.requestSubmit();
        return; // el cambio de pestaña lo hace el submit
      }

      // Para las demás pestañas, comportamiento normal
      activarTab(target);
    });
  });

    // ====== SUBMIT DEL FORMULARIO DE BÚSQUEDA ======
  form.addEventListener("submit", async (e) => {
    e.preventDefault();

    // Validación previa
    const valido = validarCamposBusqueda();
    if (!valido) return;

    try {
      const respuesta = await fetch("/buscar_habitaciones", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          fecha_inicio: fechaInicio.value,
          fecha_fin: fechaFin.value,
          pasajeros: pasajeros.value,
        }),
      });

      const data = await respuesta.json();

      contHabitaciones.innerHTML = "";

      if (data.ok) {
        if (!data.habitaciones || data.habitaciones.length === 0) {
          contHabitaciones.innerHTML =
            "<p>No hay disponibilidad para los criterios seleccionados.</p>";
        } else {
          data.habitaciones.forEach((h) => {
            contHabitaciones.innerHTML += `
              <div class="habitacion-card">
                <img src="/static/img/${h.imagen}" class="habitacion-card__img" alt="Habitación ${h.nombre}">
                <div class="habitacion-card__body">
                  <h3>${h.nombre}</h3>
                  <p>${h.descripcion}</p>
                  <p><strong>Capacidad:</strong> ${h.capacidad}</p>
                </div>
              </div>
            `;
          });
        }
      } else {
        contHabitaciones.innerHTML =
          "<p>Ocurrió un error al buscar habitaciones. Intenta nuevamente.</p>";
      }
    } catch (error) {
      console.error("Error en la búsqueda de habitaciones:", error);
      contHabitaciones.innerHTML =
        "<p>Ocurrió un error al buscar habitaciones. Intenta nuevamente.</p>";
    }
    activarTab("tab-habitaciones");
  });

});
