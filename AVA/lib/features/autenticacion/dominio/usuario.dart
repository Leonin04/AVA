import 'package:cloud_firestore/cloud_firestore.dart';

/// Rol de una cuenta de la colección `usuarios`.
enum Rol { admin, tutor }

/// Tipo de tutor (HU-01).
enum TipoTutor { centro, familiar }

/// Estado de una cuenta (HU-13). Los valores coinciden con los guardados en
/// Firestore. Si un documento no lo tiene, la cuenta está activa.
enum EstadoCuenta {
  activa,
  desactivada;

  static EstadoCuenta desde(Object? valor) =>
      valor == EstadoCuenta.desactivada.name
      ? EstadoCuenta.desactivada
      : EstadoCuenta.activa;
}

/// Administrador o tutor. Documento `usuarios/{uid}` (HU-01 a HU-03).
class Usuario {
  final String id; // uid de Firebase Authentication
  final String nombre;
  final String email;
  final Rol rol;
  final TipoTutor? tipoTutor; // null si es admin
  final EstadoCuenta estado; // HU-13
  final DateTime? desactivadaEn; // HU-13

  const Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
    this.tipoTutor,
    this.estado = EstadoCuenta.activa,
    this.desactivadaEn,
  });

  bool get esAdmin => rol == Rol.admin;
  bool get esTutor => rol == Rol.tutor;
  bool get activa => estado == EstadoCuenta.activa;

  factory Usuario.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Usuario(
      id: doc.id,
      nombre: d['nombre'] as String? ?? '',
      email: d['email'] as String? ?? '',
      rol: Rol.values.byName(d['rol'] as String? ?? 'tutor'),
      tipoTutor: d['tipoTutor'] == null
          ? null
          : TipoTutor.values.byName(d['tipoTutor'] as String),
      estado: EstadoCuenta.desde(d['estado']),
      desactivadaEn: (d['desactivadaEn'] as Timestamp?)?.toDate(),
    );
  }

  /// Datos editables. El estado se cambia aparte, con
  /// `BaseDatos.cambiarEstadoCuenta`, para no reactivar una cuenta por error
  /// al editar su nombre.
  Map<String, dynamic> toMap() => {
    'nombre': nombre,
    'email': email,
    'rol': rol.name,
    'tipoTutor': tipoTutor?.name,
  };
}
