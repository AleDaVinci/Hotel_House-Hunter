// -----------------------------------------------
// Archivo: static/js/dashboard.js
// Responsabilidad:
// - Manejar tabs dinámicos del dashboard
// - Controlar y validar fechas del formulario de búsqueda
// - Validar formulario de búsqueda (campos obligatorios)
// - Enviar búsqueda al backend vía fetch (AJAX)
// - Delegar render de habitaciones (con precios) a precios.js
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

  const hoy = new Date();
  hoy.setHours(0, 0, 0, 0);
  const hoyStr = hoy.toISOString().split("T")[0];

  fechaInicio.min = hoyStr;
  fechaFin.min = hoyStr;

  fechaInicio.addEventListener("change", () => {
    if (!fechaInicio.value) return;

    if (fechaInicio.value < hoyStr) {
      alert("La fecha de entrada no puede ser anterior a hoy.");
      fechaInicio.value = hoyStr;
    }

    fechaFin.min = fechaInicio.value;

    if (fechaFin.value && fechaFin.value < fechaInicio.value) {
      fechaFin.value = fechaInicio.value;
    }
  });

  fechaFin.addEventListener("change", () => {
    if (!fechaFin.value) return;

    if (fechaFin.value < hoyStr) {
      alert("La fecha de salida no puede ser anterior a hoy.");
      fechaFin.value = hoyStr;
      return;
    }

    if (fechaInicio.value && fechaFin.value < fechaInicio.value) {
      alert("La fecha de salida no puede ser anterior a la fecha de entrada.");
      fechaFin.value = fechaInicio.value;
    }
  });

  // ====== FUNCIONES AUXILIARES ======

  function activarTab(target) {
    buttons.forEach((b) => b.classList.remove("active"));

    const botonTarget = document.querySelector(`[data-target="${target}"]`);
    if (botonTarget) {
      botonTarget.classList.add("active");
    }

    tabs.forEach((tab) => tab.classList.remove("active"));

    const tabTarget = document.getElementById(target);
    if (tabTarget) {
      tabTarget.classList.add("active");
    }
  }

  function validarCamposBusqueda() {
    let valido = true;

    [fechaInicio, fechaFin, pasajeros].forEach((campo) => {
      campo.classList.remove("campo-error");
    });

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

    if (
      fechaInicio.value &&
      fechaFin.value &&
      fechaFin.value < fechaInicio.value
    ) {
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

      if (target === "tab-habitaciones") {
        const valido = validarCamposBusqueda();
        if (!valido) {
          form.scrollIntoView({ behavior: "smooth", block: "center" });
          return;
        }

        form.requestSubmit();
        return;
      }

      activarTab(target);
    });
  });

  // ====== SUBMIT DEL FORMULARIO DE BÚSQUEDA ======
  form.addEventListener("submit", async (e) => {
    e.preventDefault();

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

      // Delegamos el render a precios.js
      if (window.renderHabitacionesConPrecios) {
        renderHabitacionesConPrecios(data, contHabitaciones);
      } else {
        console.error(
          "⚠️ No se encontró la función renderHabitacionesConPrecios (precios.js no cargado)."
        );
        contHabitaciones.innerHTML =
          "<p>Ocurrió un error al mostrar las habitaciones.</p>";
      }
    } catch (error) {
      console.error("Error en la búsqueda de habitaciones:", error);
      contHabitaciones.innerHTML =
        "<p>Ocurrió un error al buscar habitaciones. Intenta nuevamente.</p>";
    }

    activarTab("tab-habitaciones");
  });
});
