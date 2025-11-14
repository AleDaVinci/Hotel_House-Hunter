// -----------------------------------------------
// Archivo: static/js/dashboard.js
// Responsabilidad:
//   - Manejar tabs dinámicos del dashboard
//   - Validar formulario de búsqueda
//   - Enviar búsqueda al backend vía fetch (AJAX)
//   - Renderizar habitaciones en la pestaña "Habitaciones"
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

  // ====== FUNCIONES AUXILIARES ======
  function activarTab(target) {
    buttons.forEach(b => b.classList.remove("active"));
    document.querySelector(`[data-target="${target}"]`).classList.add("active");

    tabs.forEach(tab => tab.classList.remove("active"));
    document.getElementById(target).classList.add("active");
  }

  function validarCamposBusqueda() {
    let valido = true;

    [fechaInicio, fechaFin, pasajeros].forEach(campo => {
      campo.classList.remove("campo-error");
      if (!campo.value || campo.value.trim() === "") {
        campo.classList.add("campo-error");
        valido = false;
      }
    });

    return valido;
  }

  // ====== CLIC EN LOS BOTONES DE TAB ======
  buttons.forEach(btn => {
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

        // Si los campos están completos, disparamos la búsqueda
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

    // Enviar la búsqueda al backend
    const respuesta = await fetch("/buscar_habitaciones", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        fecha_inicio: fechaInicio.value,
        fecha_fin: fechaFin.value,
        pasajeros: pasajeros.value
      })
    });

    const data = await respuesta.json();

    contHabitaciones.innerHTML = "";

    if (data.ok) {
      if (data.habitaciones.length === 0) {
        contHabitaciones.innerHTML =
          "<p>No hay disponibilidad para los criterios seleccionados.</p>";
      } else {
        data.habitaciones.forEach(h => {
          contHabitaciones.innerHTML += `
            <div class="habitacion-card">
              <img src="/static/img/${h.imagen}" class="habitacion-card__img">

              <div class="habitacion-card__body">
                <h3>${h.nombre}</h3>
                <p>${h.descripcion}</p>
                <p><strong>Capacidad:</strong> ${h.capacidad}</p>
              </div>
            </div>
          `;
        });
      }
    }

    // Cambiar automáticamente a la pestaña HABITACIONES
    activarTab("tab-habitaciones");
  });
});
