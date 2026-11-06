import 'package:cloud_firestore/cloud_firestore.dart';

import 'preferencias.dart';

/// Forma de entrar del estudiante (RF-03).
enum MetodoLogin { pin, pictograma, contrasena }

/// Documento `estudiantes/{uid}` (RF-01, RF-03, RF-04, RF-06 a RF-09).
class Estudiante {
  final String id; // uid de su cuenta de Authentication
  final String nombre;
  final String usuario; // nombre corto para entrar
  final String lugarResidencia;
  final String fotoUrl;
  final String queLeCalma;
  final String queNecesita;
  final MetodoLogin metodoLogin;
  final String? aulaId;
  final List<String> tutores; // uids de sus tutores
  final Preferencias preferencias;

  const Estudiante({
    required this.id,
    required this.nombre,
    required this.usuario,
    this.lugarResidencia = '',
    this.fotoUrl = '',
    this.queLeCalma = '',
    this.queNecesita = '',
    this.metodoLogin = MetodoLogin.pin,
    this.aulaId,
    this.tutores = const [],
    this.preferencias = const Preferencias(),
  });

  factory Estudiante.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Estudiante(
      id: doc.id,
      nombre: d['nombre'] as String? ?? '',
      usuario: d['usuario'] as String? ?? '',
      lugarResidencia: d['lugarResidencia'] as String? ?? '',
      fotoUrl: d['fotoUrl'] as String? ?? '',
      queLeCalma: d['queLeCalma'] as String? ?? '',
      queNecesita: d['queNecesita'] as String? ?? '',
      metodoLogin: MetodoLogin.values.byName(d['metodoLogin'] as String? ?? 'pin'),
      aulaId: d['aulaId'] as String?,
      tutores: List<String>.from(d['tutores'] as List? ?? const []),
      preferencias:
          Preferencias.fromMap(d['preferencias'] as Map<String, dynamic>?),
    );
  }

  /// Datos que el tutor puede editar (RF-07). No incluye tutores ni aula,
  /// que solo cambia el administrador.
  Map<String, dynamic> toMapPerfil() => {
        'nombre': nombre,
        'lugarResidencia': lugarResidencia,
        'fotoUrl': fotoUrl,
        'queLeCalma': queLeCalma,
        'queNecesita': queNecesita,
      };

  /// Documento completo, para que el administrador lo cree.
  Map<String, dynamic> toMap() => {
        ...toMapPerfil(),
        'usuario': usuario,
        'metodoLogin': metodoLogin.name,
        'aulaId': aulaId,
        'tutores': tutores,
        'preferencias': preferencias.toMap(),
      };

  Estudiante copyWith({
    String? nombre,
    String? lugarResidencia,
    String? fotoUrl,
    String? queLeCalma,
    String? queNecesita,
    MetodoLogin? metodoLogin,
    String? aulaId,
    List<String>? tutores,
    Preferencias? preferencias,
  }) =>
      Estudiante(
        id: id,
        nombre: nombre ?? this.nombre,
        usuario: usuario,
        lugarResidencia: lugarResidencia ?? this.lugarResidencia,
        fotoUrl: fotoUrl ?? this.fotoUrl,
        queLeCalma: queLeCalma ?? this.queLeCalma,
        queNecesita: queNecesita ?? this.queNecesita,
        metodoLogin: metodoLogin ?? this.metodoLogin,
        aulaId: aulaId ?? this.aulaId,
        tutores: tutores ?? this.tutores,
        preferencias: preferencias ?? this.preferencias,
      );
}
