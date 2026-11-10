import 'package:cloud_firestore/cloud_firestore.dart';

import 'preferencias.dart';

/// Forma de entrar del estudiante (HU-09).
enum MetodoLogin { pin, pictograma, contrasena }

/// Documento `estudiantes/{uid}` (HU-01, HU-02, HU-15, HU-16, HU-17, HU-19).
/// El id es el uid de la cuenta de Authentication del estudiante.
class Estudiante {
  final String id;
  final String nombre;
  final String usuario; // nombre corto para entrar (su correo interno sale de aquí)
  final String lugarResidencia;
  final String fotoUrl; // foto o avatar (Cloud Storage o ARASAAC)
  final String queLeCalma;
  final String queNecesita;
  final List<String> intereses; // HU-19
  final MetodoLogin metodoLogin;
  final String? aulaId;
  final List<String> tutores; // uids de sus tutores (centro y familiares)
  final bool puedeCambiarPreferencias; // HU-15
  final Preferencias preferencias;

  const Estudiante({
    required this.id,
    required this.nombre,
    required this.usuario,
    this.lugarResidencia = '',
    this.fotoUrl = '',
    this.queLeCalma = '',
    this.queNecesita = '',
    this.intereses = const [],
    this.metodoLogin = MetodoLogin.pin,
    this.aulaId,
    this.tutores = const [],
    this.puedeCambiarPreferencias = false,
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
      intereses: List<String>.from(d['intereses'] as List? ?? const []),
      metodoLogin:
          MetodoLogin.values.byName(d['metodoLogin'] as String? ?? 'pin'),
      aulaId: d['aulaId'] as String?,
      tutores: List<String>.from(d['tutores'] as List? ?? const []),
      puedeCambiarPreferencias: d['puedeCambiarPreferencias'] as bool? ?? false,
      preferencias:
          Preferencias.fromMap(d['preferencias'] as Map<String, dynamic>?),
    );
  }

  /// Datos del perfil que puede editar el tutor (HU-19).
  /// No incluye tutores, aula ni usuario, que solo cambia el administrador.
  Map<String, dynamic> toMapPerfil() => {
        'nombre': nombre,
        'lugarResidencia': lugarResidencia,
        'fotoUrl': fotoUrl,
        'queLeCalma': queLeCalma,
        'queNecesita': queNecesita,
        'intereses': intereses,
      };

  /// Documento completo, para que el administrador lo cree.
  Map<String, dynamic> toMap() => {
        ...toMapPerfil(),
        'usuario': usuario,
        'metodoLogin': metodoLogin.name,
        'aulaId': aulaId,
        'tutores': tutores,
        'puedeCambiarPreferencias': puedeCambiarPreferencias,
        'preferencias': preferencias.toMap(),
      };

  Estudiante copyWith({
    String? nombre,
    String? lugarResidencia,
    String? fotoUrl,
    String? queLeCalma,
    String? queNecesita,
    List<String>? intereses,
    MetodoLogin? metodoLogin,
    String? aulaId,
    List<String>? tutores,
    bool? puedeCambiarPreferencias,
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
        intereses: intereses ?? this.intereses,
        metodoLogin: metodoLogin ?? this.metodoLogin,
        aulaId: aulaId ?? this.aulaId,
        tutores: tutores ?? this.tutores,
        puedeCambiarPreferencias:
            puedeCambiarPreferencias ?? this.puedeCambiarPreferencias,
        preferencias: preferencias ?? this.preferencias,
      );
}
