import '../../../core/constantes/paleta.dart';
import '../../../core/modelos/recurso_visual.dart';
import '../../autenticacion/dominio/metodo_acceso.dart';
import 'preferencias_accesibilidad.dart';

/// Perfil de un estudiante tal como lo usa la interfaz (HU-18, RI01).
///
/// En Firebase se guarda en el documento `estudiantes/{id}` con el esquema
/// de `estudiante.dart`; la conversión está en
/// `repositorio_estudiantes_firebase.dart`.
class Estudiante {
  const Estudiante({
    required this.id,
    required this.nombre,
    required this.idAula,
    required this.metodoAcceso,
    this.usuario = '',
    this.lugarResidencia = '',
    this.avatar,
    this.color = ColorPastel.cielo,
    this.intereses = const [],
    this.necesidades = '',
    this.autorregulacion = '',
    this.observaciones = '',
    this.tutores = const [],
    this.preferencias = const PreferenciasAccesibilidad(),
    this.puedeModificarPreferencias = false,
    this.puedeGestionarTareas = false,
  });

  final String id;
  final String nombre;
  final String? idAula;
  final MetodoAcceso metodoAcceso;

  /// Nombre corto con el que se crea su cuenta de acceso.
  final String usuario;

  /// Lugar de residencia (RI01).
  final String lugarResidencia;

  /// Foto o pictograma que identifica al estudiante.
  final RecursoVisual? avatar;

  /// Color de su tarjeta en la pantalla de la clase.
  final ColorPastel color;

  final List<String> intereses;
  final String necesidades;

  /// Elementos que le ayudan a calmarse.
  final String autorregulacion;

  /// Notas del tutor sobre su progreso.
  final String observaciones;

  /// Cuentas de sus tutores (del centro y familiares), para los permisos
  /// (HU-16).
  final List<String> tutores;

  final PreferenciasAccesibilidad preferencias;

  /// El tutor permite que el estudiante cambie sus preferencias (HU-14).
  final bool puedeModificarPreferencias;

  /// El tutor permite que el estudiante cree y borre sus tareas (HU-03).
  final bool puedeGestionarTareas;

  Estudiante copyWith({
    String? nombre,
    String? idAula,
    bool quitarAula = false,
    MetodoAcceso? metodoAcceso,
    String? lugarResidencia,
    RecursoVisual? avatar,
    bool quitarAvatar = false,
    ColorPastel? color,
    List<String>? intereses,
    String? necesidades,
    String? autorregulacion,
    String? observaciones,
    List<String>? tutores,
    PreferenciasAccesibilidad? preferencias,
    bool? puedeModificarPreferencias,
    bool? puedeGestionarTareas,
  }) {
    return Estudiante(
      id: id,
      nombre: nombre ?? this.nombre,
      idAula: quitarAula ? null : idAula ?? this.idAula,
      metodoAcceso: metodoAcceso ?? this.metodoAcceso,
      usuario: usuario,
      lugarResidencia: lugarResidencia ?? this.lugarResidencia,
      avatar: quitarAvatar ? null : avatar ?? this.avatar,
      color: color ?? this.color,
      intereses: intereses ?? this.intereses,
      necesidades: necesidades ?? this.necesidades,
      autorregulacion: autorregulacion ?? this.autorregulacion,
      observaciones: observaciones ?? this.observaciones,
      tutores: tutores ?? this.tutores,
      preferencias: preferencias ?? this.preferencias,
      puedeModificarPreferencias:
          puedeModificarPreferencias ?? this.puedeModificarPreferencias,
      puedeGestionarTareas: puedeGestionarTareas ?? this.puedeGestionarTareas,
    );
  }

  Map<String, Object?> toMap() => {
    'nombre': nombre,
    'idAula': idAula,
    'metodoAcceso': metodoAcceso.toMap(),
    'usuario': usuario,
    'lugarResidencia': lugarResidencia,
    'avatar': avatar?.toMap(),
    'color': color.name,
    'intereses': intereses,
    'necesidades': necesidades,
    'autorregulacion': autorregulacion,
    'observaciones': observaciones,
    'tutores': tutores,
    'preferencias': preferencias.toMap(),
    'puedeModificarPreferencias': puedeModificarPreferencias,
    'puedeGestionarTareas': puedeGestionarTareas,
  };

  factory Estudiante.fromMap(String id, Map<String, Object?> datos) =>
      Estudiante(
        id: id,
        nombre: datos['nombre'] as String? ?? '',
        idAula: datos['idAula'] as String?,
        metodoAcceso: MetodoAcceso.fromMap(datos['metodoAcceso']),
        usuario: datos['usuario'] as String? ?? id,
        lugarResidencia: datos['lugarResidencia'] as String? ?? '',
        avatar: RecursoVisual.fromMap(datos['avatar']),
        color: ColorPastel.porNombre(datos['color'] as String?),
        intereses: [
          for (final interes in datos['intereses'] as List? ?? const [])
            interes as String,
        ],
        necesidades: datos['necesidades'] as String? ?? '',
        autorregulacion: datos['autorregulacion'] as String? ?? '',
        observaciones: datos['observaciones'] as String? ?? '',
        tutores: [
          for (final tutor in datos['tutores'] as List? ?? const [])
            tutor as String,
        ],
        preferencias: PreferenciasAccesibilidad.fromMap(datos['preferencias']),
        puedeModificarPreferencias:
            datos['puedeModificarPreferencias'] as bool? ?? false,
        puedeGestionarTareas: datos['puedeGestionarTareas'] as bool? ?? false,
      );
}
