import 'package:cloud_firestore/cloud_firestore.dart';

import '../../perfil/dominio/estudiante.dart';

/// Documento `acceso/{estudianteId}` (HU-09).
///
/// Es la "ficha pública" del alumno para la pantalla de la tableta
/// "elige tu aula → elige quién eres → escribe tu clave".
/// Solo tiene lo imprescindible: nada de datos personales del perfil.
class Acceso {
  final String id; // = id del estudiante
  final String nombre; // nombre de pila
  final String fotoUrl; // foto o avatar
  final String? aulaId;
  final MetodoLogin metodoLogin;
  final String usuario; // para construir su correo interno

  const Acceso({
    required this.id,
    required this.nombre,
    this.fotoUrl = '',
    this.aulaId,
    this.metodoLogin = MetodoLogin.pin,
    required this.usuario,
  });

  factory Acceso.deEstudiante(Estudiante e) => Acceso(
        id: e.id,
        nombre: e.nombre.split(' ').first,
        fotoUrl: e.fotoUrl,
        aulaId: e.aulaId,
        metodoLogin: e.metodoLogin,
        usuario: e.usuario,
      );

  factory Acceso.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Acceso(
      id: doc.id,
      nombre: d['nombre'] as String? ?? '',
      fotoUrl: d['fotoUrl'] as String? ?? '',
      aulaId: d['aulaId'] as String?,
      metodoLogin:
          MetodoLogin.values.byName(d['metodoLogin'] as String? ?? 'pin'),
      usuario: d['usuario'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'fotoUrl': fotoUrl,
        'aulaId': aulaId,
        'metodoLogin': metodoLogin.name,
        'usuario': usuario,
      };
}
