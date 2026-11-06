/// Formas de consultar la agenda (HU-09 y HU-10).
enum VistaAgenda {
  semanal('Semana'),
  diaria('Día'),
  siguienteTarea('Siguiente tarea');

  const VistaAgenda(this.nombre);

  final String nombre;
}
