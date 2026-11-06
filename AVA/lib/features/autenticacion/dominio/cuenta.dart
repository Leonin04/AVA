import 'rol.dart';

/// Cuenta de usuario del sistema (HU-01).
///
/// El [id] es el nombre de usuario y es único. En las cuentas de
/// estudiante coincide con el identificador de su perfil.
class Cuenta {
  const Cuenta({
    required this.id,
    required this.nombre,
    required this.rol,
    this.email,
  });

  final String id;
  final String nombre;
  final Rol rol;

  /// Correo para recuperar la contraseña (tutores y administradores).
  final String? email;

  bool get esGestion => rol == Rol.administrador || rol == Rol.tutor;

  Cuenta copyWith({String? nombre, Rol? rol, String? email}) => Cuenta(
    id: id,
    nombre: nombre ?? this.nombre,
    rol: rol ?? this.rol,
    email: email ?? this.email,
  );

  Map<String, Object?> toMap() => {
    'nombre': nombre,
    'rol': rol.name,
    'email': email,
  };

  factory Cuenta.fromMap(String id, Map<String, Object?> datos) => Cuenta(
    id: id,
    nombre: datos['nombre'] as String? ?? '',
    rol: Rol.porNombre(datos['rol'] as String?),
    email: datos['email'] as String?,
  );
}
