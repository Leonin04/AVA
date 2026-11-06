import '../../autenticacion/dominio/metodo_acceso.dart';
import 'preferencias_accesibilidad.dart';

/// Estudiante del centro con su configuración de acceso y accesibilidad.
class Estudiante {
  const Estudiante({
    required this.id,
    required this.nombre,
    required this.idAula,
    required this.metodoAcceso,
    this.urlAvatar,
    this.preferencias = const PreferenciasAccesibilidad(),
  });

  final String id;
  final String nombre;
  final String idAula;
  final MetodoAcceso metodoAcceso;
  final String? urlAvatar;
  final PreferenciasAccesibilidad preferencias;

  Estudiante copyWith({PreferenciasAccesibilidad? preferencias}) {
    return Estudiante(
      id: id,
      nombre: nombre,
      idAula: idAula,
      metodoAcceso: metodoAcceso,
      urlAvatar: urlAvatar,
      preferencias: preferencias ?? this.preferencias,
    );
  }
}
