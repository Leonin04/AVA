import 'rol.dart';

/// Cuenta de usuario del sistema (HU-01).
///
/// El [id] es único. En las cuentas de estudiante coincide con el
/// identificador de su perfil. Con Firebase es el uid de Authentication.
class Cuenta {
  const Cuenta({
    required this.id,
    required this.nombre,
    required this.rol,
    this.email,
    this.usuario,
    this.esFamiliar = false,
  });

  final String id;
  final String nombre;
  final Rol rol;

  /// Correo con el que entran tutores y administradores, y al que se envía
  /// la recuperación de la contraseña (HU-17).
  final String? email;

  /// Nombre corto con el que se crea la cuenta de un estudiante.
  final String? usuario;

  /// Tutor familiar en lugar de tutor del centro (RF-04).
  final bool esFamiliar;

  bool get esGestion => rol == Rol.administrador || rol == Rol.tutor;

  Cuenta copyWith({
    String? nombre,
    Rol? rol,
    String? email,
    bool? esFamiliar,
  }) => Cuenta(
    id: id,
    nombre: nombre ?? this.nombre,
    rol: rol ?? this.rol,
    email: email ?? this.email,
    usuario: usuario,
    esFamiliar: esFamiliar ?? this.esFamiliar,
  );

  Map<String, Object?> toMap() => {
    'nombre': nombre,
    'rol': rol.name,
    'email': email,
    'usuario': usuario,
    'esFamiliar': esFamiliar,
  };

  factory Cuenta.fromMap(String id, Map<String, Object?> datos) => Cuenta(
    id: id,
    nombre: datos['nombre'] as String? ?? '',
    rol: Rol.porNombre(datos['rol'] as String?),
    email: datos['email'] as String?,
    usuario: datos['usuario'] as String?,
    esFamiliar: datos['esFamiliar'] as bool? ?? false,
  );
}
