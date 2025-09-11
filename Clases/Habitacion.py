habitaciones = []

while True:
    habitacion = {
        'nombre': input("Ingrese el nombre de la habitación: "),
        'descripcion': input("Ingrese la descripción: "),
        'capacidad': int(input("Ingrese la capacidad: ")),
        'codigo_habitacion': int(input("Ingrese el código de habitación: ")),
        'precio_noche': float(input("Ingrese el precio por noche: ")),
        'activa': input("¿Está activa? (s/n): ").lower() == "s",
        'estado_limpieza': input("¿Está limpia? (s/n): ").lower() == "s"
    }

    habitaciones.append(habitacion)
    print("\nHabitación agregada con éxito!\n")

    continuar = input("¿Desea agregar otra habitación? (s/n): ").lower()
    if continuar != "s":
        break


print("\nListado de habitaciones cargadas:")
for h in habitaciones:
    print(f"""
    Código: {h['codigo_habitacion']}
    Nombre: {h['nombre']}
    Descripción: {h['descripcion']}
    Capacidad: {h['capacidad']} persona(s)
    Precio por noche: ${h['precio_noche']:.2f}
    Activa: {"Sí" if h['activa'] else "No"}
    Limpieza: {"Limpia" if h['estado_limpieza'] else "Pendiente"}
    """)
    
print(f"\nTotal de habitaciones cargadas: {len(habitaciones)}")