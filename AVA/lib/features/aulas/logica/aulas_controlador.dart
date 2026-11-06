import '../../../core/utilidades/controlador_carga.dart';
import '../dominio/aula.dart';
import '../dominio/repositorio_aulas.dart';

/// Carga las aulas que se muestran en la pantalla de inicio.
class AulasControlador extends ControladorCarga<List<Aula>> {
  AulasControlador(this._repositorio);

  final RepositorioAulas _repositorio;

  @override
  Future<List<Aula>> obtenerDatos() => _repositorio.obtenerAulas();

  @override
  String get mensajeErrorCarga => 'No se han podido cargar las clases.';
}
