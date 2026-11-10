import '../../../core/constantes/paleta.dart';
import '../../../core/servicios/almacen_simulado.dart';
import '../../../core/utilidades/orden_alfabetico.dart';
import '../../perfil/dominio/perfil_estudiante.dart';
import '../../perfil/dominio/repositorio_estudiantes_simulado.dart';
import 'clave_acceso.dart';
import 'cuenta.dart';
import 'repositorio_autenticacion_simulado.dart';
import 'repositorio_cuentas.dart';
import 'rol.dart';

/// Cuentas guardadas en el [AlmacenSimulado], para las pruebas automáticas.
class RepositorioCuentasSimulado implements RepositorioCuentas {
  RepositorioCuentasSimulado(this._almacen);

  static const coleccion = 'cuentas';

  final AlmacenSimulado _almacen;

  @override
  Future<List<Cuenta>> listar() async => [
    for (final (id, datos) in _almacen.listar(coleccion))
      Cuenta.fromMap(id, datos),
  ]..sort((a, b) => compararAlfabeticamente(a.nombre, b.nombre));

  @override
  Future<Cuenta?> obtener(String id) async {
    final datos = _almacen.obtener(coleccion, id);
    return datos == null ? null : Cuenta.fromMap(id, datos);
  }

  @override
  Future<String> crear(
    Cuenta cuenta,
    ClaveAcceso clave, {
    String? idAula,
  }) async {
    final email = cuenta.email?.trim().toLowerCase();
    final id = cuenta.id.isNotEmpty
        ? cuenta.id
        : (cuenta.usuario ?? email?.split('@').first ?? '');
    final correoRepetido =
        email != null &&
        _almacen
            .listar(
              coleccion,
              donde: (d) => (d['email'] as String?)?.toLowerCase() == email,
            )
            .isNotEmpty;
    if (id.isEmpty || _almacen.existe(coleccion, id) || correoRepetido) {
      throw CuentaDuplicada(email ?? id);
    }

    _almacen.guardar(coleccion, id, {...cuenta.toMap(), 'usuario': id});
    _almacen.guardar(
      RepositorioAutenticacionSimulado.coleccion,
      id,
      clave.toMap(),
    );

    if (cuenta.rol == Rol.estudiante) {
      final total = _almacen.listar(RepositorioEstudiantesSimulado.coleccion);
      _almacen.guardar(
        RepositorioEstudiantesSimulado.coleccion,
        id,
        Estudiante(
          id: id,
          nombre: cuenta.nombre,
          usuario: id,
          idAula: idAula,
          metodoAcceso: clave.metodo,
          color: ColorPastel.paraIndice(total.length),
        ).toMap(),
      );
    }
    return id;
  }

  @override
  Future<void> actualizar(Cuenta cuenta) async {
    if (!_almacen.existe(coleccion, cuenta.id)) {
      throw StateError('No existe la cuenta ${cuenta.id}');
    }
    _almacen.guardar(coleccion, cuenta.id, cuenta.toMap());
  }
}
