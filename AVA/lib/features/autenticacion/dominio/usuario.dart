import 'package:cloud_firestore/cloud_firestore.dart';

/// Rol de una cuenta de la colección `usuarios`.
enum Rol { admin, tutor }

/// Tipo de tutor (HU-01).
enum TipoTutor { centro, familiar }

/// Administrador o tutor. Documento `usuarios/{uid}` (HU-01 a HU-03).
class Usuario {
  final String id; // uid de Firebase Authentication
  final String nombre;
  final String email;
  final Rol rol;
  final TipoTutor? tipoTutor; // null si es admin

  const Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
    this.tipoTutor,
  });

  bool get esAdmin => rol == Rol.admin;
  bool get esTutor => rol == Rol.tutor;

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
    );
  }

  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'email': email,
        'rol': rol.name,
        'tipoTutor': tipoTutor?.name,
      };
}
