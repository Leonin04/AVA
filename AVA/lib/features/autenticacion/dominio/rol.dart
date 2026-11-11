/// Rol de una cuenta, que limita las funciones a las que accede (HU-03).
enum Rol {
  administrador('Administrador'),
  tutor('Tutor'),
  estudiante('Estudiante');

  const Rol(this.nombre);

  final String nombre;

  static Rol porNombre(String? nombre) =>
      values.firstWhere((rol) => rol.name == nombre, orElse: () => estudiante);
}
