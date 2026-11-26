import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/servicios/autenticacion.dart';
import '../../../core/servicios/base_datos.dart';
import '../../../core/utilidades/controlador_carga.dart';
import '../../../core/utilidades/orden_alfabetico.dart';
import '../../perfil/dominio/conversion_firestore.dart';
import '../../perfil/dominio/estudiante.dart' as bd;
import '../../perfil/dominio/preferencias.dart' as bd;
import '../../perfil/dominio/preferencias_accesibilidad.dart';
import 'clave_acceso.dart';
import 'cuenta.dart';
import 'repositorio_autenticacion_firebase.dart';
import 'repositorio_cuentas.dart';
import 'rol.dart';
import 'usuario.dart' as bd;

/// Cuentas en Firebase: admin y tutores en `usuarios` y estudiantes en
/// `estudiantes`, creadas con el servicio `Autenticacion`.
class RepositorioCuentasFirebase implements RepositorioCuentas {
  RepositorioCuentasFirebase({
    BaseDatos? baseDatos,
    Autenticacion? autenticacion,
    FirebaseFirestore? firestore,
  }) : _bd = baseDatos ?? BaseDatos(),
       _auth = autenticacion ?? Autenticacion(),
       _db = firestore ?? FirebaseFirestore.instance;

  final BaseDatos _bd;
  final Autenticacion _auth;
  final FirebaseFirestore _db;

  @override
  Future<List<Cuenta>> listar() async {
    final personal = await _bd.usuarios().first;
    final estudiantes = await _db.collection('estudiantes').get();
    return [
      for (final u in personal) RepositorioAutenticacionFirebase.cuentaDesde(u),
      for (final doc in estudiantes.docs) _cuentaEstudiante(doc.id, doc.data()),
    ]..sort((a, b) => compararAlfabeticamente(a.nombre, b.nombre));
  }

  @override
  Future<Cuenta?> obtener(String id) async {
    final usuario = await _bd.obtenerUsuario(id);
    if (usuario != null) {
      return RepositorioAutenticacionFirebase.cuentaDesde(usuario);
    }
    final estudiante = await _db.collection('estudiantes').doc(id).get();
    final datos = estudiante.data();
    return datos == null ? null : _cuentaEstudiante(id, datos);
  }

  @override
  Future<String> crear(
    Cuenta cuenta,
    ClaveAcceso clave, {
    String? idAula,
  }) async {
    try {
      if (cuenta.rol != Rol.estudiante) {
        return await _auth.crearCuentaPersonal(
          nombre: cuenta.nombre,
          correo: cuenta.email ?? '',
          contrasena: (clave as ClaveContrasena).texto,
          rol: cuenta.rol == Rol.administrador ? bd.Rol.admin : bd.Rol.tutor,
          tipoTutor: cuenta.esFamiliar
              ? bd.TipoTutor.familiar
              : bd.TipoTutor.centro,
        );
      }

      // El tutor responsable del aula pasa a ser tutor del alumno (HU-16).
      final tutor = idAula == null
          ? null
          : (await _db.collection('aulas').doc(idAula).get())
                    .data()?['tutorResponsable']
                as String?;
      final preferencias = ConversionFirestore.preferenciasA(
        const PreferenciasAccesibilidad(),
      );
      return await _auth.crearCuentaEstudiante(
        bd.Estudiante(
          id: '',
          nombre: cuenta.nombre,
          usuario: cuenta.usuario ?? cuenta.id,
          metodoLogin: ConversionFirestore.metodoA(clave.metodo),
          aulaId: idAula,
          tutores: [if (tutor != null && tutor.isNotEmpty) tutor],
          preferencias: bd.Preferencias.fromMap(preferencias),
        ),
        RepositorioAutenticacionFirebase.entradaDe(clave),
      );
    } on ErrorAcceso catch (error) {
      if (error.mensaje.startsWith('Ya existe')) {
        throw CuentaDuplicada(cuenta.email ?? cuenta.usuario ?? cuenta.id);
      }
      throw ErrorConMensaje(error.mensaje);
    }
  }

  @override
  Future<void> actualizar(Cuenta cuenta) async {
    // El nombre de los estudiantes se cambia en su perfil.
    if (cuenta.rol == Rol.estudiante) return;
    await _bd.guardarUsuario(
      bd.Usuario(
        id: cuenta.id,
        nombre: cuenta.nombre,
        email: cuenta.email ?? '',
        rol: cuenta.rol == Rol.administrador ? bd.Rol.admin : bd.Rol.tutor,
        tipoTutor: cuenta.rol == Rol.tutor
            ? (cuenta.esFamiliar ? bd.TipoTutor.familiar : bd.TipoTutor.centro)
            : null,
      ),
    );
  }

  @override
  Future<void> cambiarActivacion(Cuenta cuenta, {required bool activa}) =>
      _bd.cambiarEstadoCuenta(
        cuenta.id,
        activa: activa,
        esEstudiante: cuenta.rol == Rol.estudiante,
      );

  /// Cuenta de un estudiante a partir de su documento `estudiantes/{id}`.
  static Cuenta _cuentaEstudiante(String id, Map<String, dynamic> datos) =>
      Cuenta(
        id: id,
        nombre: datos['nombre'] as String? ?? '',
        rol: Rol.estudiante,
        usuario: datos['usuario'] as String?,
        activa:
            bd.EstadoCuenta.desde(datos['estado']) == bd.EstadoCuenta.activa,
        desactivadaEn: (datos['desactivadaEn'] as Timestamp?)?.toDate(),
      );
}
