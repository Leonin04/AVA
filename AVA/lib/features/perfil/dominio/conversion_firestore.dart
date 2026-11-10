import 'dart:convert';
import 'dart:typed_data';

import '../../../core/constantes/paleta.dart';
import '../../../core/modelos/recurso_visual.dart';
import '../../agenda/dominio/vista_agenda.dart';
import '../../autenticacion/dominio/metodo_acceso.dart';
import 'estudiante.dart' as bd;
import 'perfil_estudiante.dart';
import 'preferencias_accesibilidad.dart';

/// Conversión entre los documentos de Firestore (esquema de
/// `database/README.md`) y los modelos que usa la interfaz.
///
/// Los datos que la interfaz necesita y el esquema no tenía se guardan en
/// campos nuevos que no afectan a los demás:
/// - `estudiantes/{id}`: `color`, `observaciones` y `puedeGestionarTareas`.
/// - `preferencias.ava`: color principal, modo oscuro (junto al alto
///   contraste), evitar toques dobles y vistas de la agenda.
abstract final class ConversionFirestore {
  static const _tamanos = {
    TamanoTexto.normal: 22.0,
    TamanoTexto.grande: 27.5,
    TamanoTexto.muyGrande: 33.0,
  };

  static MetodoAcceso metodoDesde(String? metodoLogin) => switch (metodoLogin) {
    'pictograma' => const AccesoConPictogramas(),
    'contrasena' => const AccesoConContrasena(),
    _ => const AccesoConPin(),
  };

  static bd.MetodoLogin metodoA(MetodoAcceso metodo) => switch (metodo) {
    AccesoConPictogramas() => bd.MetodoLogin.pictograma,
    AccesoConContrasena() => bd.MetodoLogin.contrasena,
    AccesoConPin() => bd.MetodoLogin.pin,
  };

  /// Estudiante a partir del documento `estudiantes/{id}` completo.
  static Estudiante estudianteDesde(String id, Map<String, dynamic> d) {
    return Estudiante(
      id: id,
      nombre: d['nombre'] as String? ?? '',
      usuario: d['usuario'] as String? ?? '',
      idAula: d['aulaId'] as String?,
      metodoAcceso: metodoDesde(d['metodoLogin'] as String?),
      lugarResidencia: d['lugarResidencia'] as String? ?? '',
      avatar: RecursoVisual.desdeUrl(d['fotoUrl'] as String?),
      color: d['color'] == null
          ? ColorPastel.paraIndice(id.hashCode)
          : ColorPastel.porNombre(d['color'] as String?),
      intereses: List<String>.from(d['intereses'] as List? ?? const []),
      necesidades: d['queNecesita'] as String? ?? '',
      autorregulacion: d['queLeCalma'] as String? ?? '',
      observaciones: d['observaciones'] as String? ?? '',
      tutores: List<String>.from(d['tutores'] as List? ?? const []),
      preferencias: preferenciasDesde(
        d['preferencias'] as Map<String, dynamic>?,
      ),
      puedeModificarPreferencias:
          d['puedeCambiarPreferencias'] as bool? ?? false,
      puedeGestionarTareas: d['puedeGestionarTareas'] as bool? ?? true,
    );
  }

  static PreferenciasAccesibilidad preferenciasDesde(Map<String, dynamic>? m) {
    const porDefecto = PreferenciasAccesibilidad();
    if (m == null) return porDefecto;
    final comunicacion = m['comunicacion'] as Map<String, dynamic>? ?? {};
    final visual = m['visual'] as Map<String, dynamic>? ?? {};
    final ava = m['ava'] as Map<String, dynamic>? ?? {};

    final colores = visual['colores'] as String?;
    final tamano = (visual['tamanoLetra'] as num?)?.toDouble() ?? 22;
    final vistas = {
      for (final nombre in ava['vistasAgenda'] as List? ?? const [])
        ?VistaAgenda.porNombre(nombre as String),
    };

    return PreferenciasAccesibilidad(
      mostrarPictogramas: comunicacion['pictogramas'] as bool? ?? true,
      mostrarTexto: comunicacion['texto'] as bool? ?? true,
      leerEnVoz: comunicacion['voz'] as bool? ?? false,
      altoContraste: colores == 'alto_contraste',
      modoOscuro: colores == 'oscuro' || (ava['modoOscuro'] as bool? ?? false),
      letraClara: (visual['tipografia'] as String? ?? 'Atkinson').contains(
        'Atkinson',
      ),
      tamanoTexto: tamano < 25
          ? TamanoTexto.normal
          : tamano < 31
          ? TamanoTexto.grande
          : TamanoTexto.muyGrande,
      menuArriba: visual['posicionMenus'] == 'arriba',
      color: ColorPastel.porNombre(ava['color'] as String?),
      filtroAntitemblor: ava['filtroAntitemblor'] as bool? ?? false,
      vistasAgenda: vistas.isEmpty ? porDefecto.vistasAgenda : vistas,
    );
  }

  /// Mapa `preferencias` para guardar. Conserva los campos de [anteriores]
  /// que la interfaz no maneja (imágenes, sonido, posición de botones...).
  static Map<String, dynamic> preferenciasA(
    PreferenciasAccesibilidad p, {
    Map<String, dynamic>? anteriores,
  }) {
    final comunicacion = {
      ...?anteriores?['comunicacion'] as Map<String, dynamic>?,
      'pictogramas': p.mostrarPictogramas,
      'texto': p.mostrarTexto,
      'voz': p.leerEnVoz,
    };
    final visual = {
      ...?anteriores?['visual'] as Map<String, dynamic>?,
      'colores': p.altoContraste
          ? 'alto_contraste'
          : p.modoOscuro
          ? 'oscuro'
          : 'claro',
      'tipografia': p.letraClara ? 'Atkinson Hyperlegible' : 'Estándar',
      'tamanoLetra': _tamanos[p.tamanoTexto],
      'posicionMenus': p.menuArriba ? 'arriba' : 'abajo',
    };
    return {
      ...?anteriores,
      'comunicacion': comunicacion,
      'visual': visual,
      'ava': {
        'color': p.color.name,
        'modoOscuro': p.modoOscuro,
        'filtroAntitemblor': p.filtroAntitemblor,
        'vistasAgenda': [for (final v in p.vistasAgenda) v.name],
      },
    };
  }

  /// Bytes de una foto incrustada (`data:image/...;base64,...`), para
  /// subirla a Cloud Storage, o `null` si ya es una dirección.
  static ({Uint8List bytes, String tipo})? fotoIncrustada(
    RecursoVisual? recurso,
  ) {
    if (recurso is! FotoPropia || !recurso.url.startsWith('data:')) {
      return null;
    }
    final url = recurso.url;
    final tipo = url.substring(5, url.indexOf(';'));
    return (
      bytes: base64Decode(url.substring(url.indexOf(',') + 1)),
      tipo: tipo,
    );
  }
}
