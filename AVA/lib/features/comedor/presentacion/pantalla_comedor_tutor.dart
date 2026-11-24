import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constantes/dimensiones.dart';
import '../../../core/utilidades/controlador_carga.dart';
import '../../../core/utilidades/formato_fecha.dart';
import '../../../core/widgets/pantalla_gestion.dart';
import '../../../core/widgets/vista_carga.dart';
import '../../autenticacion/dominio/cuenta.dart';
import '../../autenticacion/logica/permisos.dart';
import '../../aulas/dominio/ficha_aula.dart';
import '../../aulas/dominio/repositorio_aulas.dart';
import '../../perfil/dominio/perfil_estudiante.dart';
import '../../perfil/dominio/repositorio_estudiantes.dart';
import '../dominio/comedor.dart';
import '../dominio/repositorio_comedor.dart';
import '../logica/comedor_controladores.dart';
import '../logica/listado_cocina.dart';

/// Comedor para el tutor del centro y la administración (HU-23 a HU-25):
/// revisar y corregir la asistencia de un aula en un día, nombrar al
/// encargado, gestionar las dietas y generar el listado para cocina.
class PantallaComedorTutor extends StatefulWidget {
  const PantallaComedorTutor({super.key, required this.cuenta});

  final Cuenta cuenta;

  @override
  State<PantallaComedorTutor> createState() => _PantallaComedorTutorState();
}

class _PantallaComedorTutorState extends State<PantallaComedorTutor> {
  late final ComedorTutorControlador _panel;
  ListaComedorControlador? _lista;

  @override
  void initState() {
    super.initState();
    _panel = ComedorTutorControlador(
      comedor: context.read<RepositorioComedor>(),
      estudiantes: context.read<RepositorioEstudiantes>(),
      aulas: context.read<RepositorioAulas>(),
      cuenta: widget.cuenta,
    );
    unawaited(_cargar());
  }

  Future<void> _cargar() async {
    await _panel.cargar();
    _crearLista();
  }

  /// Vuelve a crear la lista al cambiar de aula o de día.
  void _crearLista() {
    final aula = _panel.aula;
    _lista?.dispose();
    _lista = aula == null
        ? null
        : ListaComedorControlador(
            comedor: context.read<RepositorioComedor>(),
            estudiantes: context.read<RepositorioEstudiantes>(),
            aula: aula,
            fecha: _panel.fecha,
            origen: OrigenAsistencia.tutor,
            idActor: widget.cuenta.id,
          );
    unawaited(_lista?.cargar());
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _lista?.dispose();
    _panel.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final elegida = await showDatePicker(
      context: context,
      initialDate: _panel.fecha,
      firstDate: DateTime(2026),
      lastDate: DateTime(2030),
      selectableDayPredicate: CalculosComedor.esDiaDeComedor,
    );
    if (elegida != null) {
      _panel.elegir(fecha: elegida);
      _crearLista();
    }
  }

  Future<void> _verListado() async {
    final avisos = ScaffoldMessenger.of(context);
    try {
      final listado = await _panel.listado();
      if (mounted) {
        await showDialog<void>(
          context: context,
          builder: (_) => _DialogoListado(listado: listado),
        );
      }
    } on ErrorConMensaje catch (error) {
      avisos.showSnackBar(SnackBar(content: Text(error.mensaje)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PantallaGestion(
      titulo: 'Comedor',
      acciones: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: FilledButton.icon(
            onPressed: _verListado,
            icon: const Icon(Icons.receipt_long_rounded),
            label: const Text('Listado para cocina'),
          ),
        ),
      ],
      cuerpo: VistaCarga<List<Aula>>(
        controlador: _panel,
        constructor: (context, aulas) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: Dimensiones.espaciado,
              runSpacing: Dimensiones.espaciadoPequeno,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                DropdownButton<Aula>(
                  value: _panel.aula,
                  hint: const Text('Elige un aula'),
                  items: [
                    for (final aula in aulas)
                      DropdownMenuItem(value: aula, child: Text(aula.nombre)),
                  ],
                  onChanged: (aula) {
                    _panel.elegir(aula: aula);
                    _crearLista();
                  },
                ),
                OutlinedButton.icon(
                  onPressed: _elegirFecha,
                  icon: const Icon(Icons.event_rounded),
                  label: Text(FormatoFecha.diaCompleto(_panel.fecha)),
                ),
              ],
            ),
            if (_lista case final lista?)
              _ListaTutor(lista: lista, panel: _panel, cuenta: widget.cuenta),
          ],
        ),
      ),
    );
  }
}

class _ListaTutor extends StatelessWidget {
  const _ListaTutor({
    required this.lista,
    required this.panel,
    required this.cuenta,
  });

  final ListaComedorControlador lista;
  final ComedorTutorControlador panel;
  final Cuenta cuenta;

  Future<void> _abrirDieta(BuildContext context, Estudiante estudiante) =>
      showDialog<void>(
        context: context,
        builder: (_) => _DialogoDieta(
          controlador: DietaControlador(
            comedor: context.read<RepositorioComedor>(),
            estudiante: estudiante,
            cuenta: cuenta,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return VistaCarga<List<FilaComedor>>(
      controlador: lista,
      constructor: (context, filas) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TituloSeccion(
            'Encargado del comedor',
            descripcion:
                'El alumno que pasa la lista de su clase desde la tableta.',
          ),
          DropdownButton<String?>(
            value: panel.aula?.idEncargadoComedor,
            isExpanded: true,
            items: [
              const DropdownMenuItem(value: null, child: Text('Nadie')),
              for (final fila in filas)
                DropdownMenuItem(
                  value: fila.estudiante.id,
                  child: Text(fila.estudiante.nombre),
                ),
            ],
            onChanged: (id) => panel.elegirEncargado(
              filas.where((f) => f.estudiante.id == id).firstOrNull?.estudiante,
            ),
          ),
          TituloSeccion(
            'Quién come',
            descripcion: lista.sinResponder == 0
                ? 'Han respondido todos.'
                : 'Faltan ${lista.sinResponder} por responder.',
          ),
          for (final fila in filas)
            Card(
              child: ListTile(
                title: Text(fila.estudiante.nombre),
                subtitle: Text(
                  fila.asistencia == null
                      ? 'Sin responder'
                      : 'Registrado por: ${fila.asistencia!.origen.nombre}',
                ),
                trailing: Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SegmentedButton<bool>(
                      emptySelectionAllowed: true,
                      segments: const [
                        ButtonSegment(value: true, label: Text('Come')),
                        ButtonSegment(value: false, label: Text('No come')),
                      ],
                      selected: {?fila.asistencia?.come},
                      onSelectionChanged: (s) => s.isEmpty
                          ? null
                          : lista.marcar(fila.estudiante, come: s.first),
                    ),
                    if (Permisos.puedeGestionarDietas(cuenta))
                      TextButton.icon(
                        onPressed: () => _abrirDieta(context, fila.estudiante),
                        icon: const Icon(Icons.no_food_rounded),
                        label: const Text('Dieta'),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Editor de la dieta de un estudiante con sus cambios (HU-24, T-116,
/// T-118).
class _DialogoDieta extends StatefulWidget {
  const _DialogoDieta({required this.controlador});

  final DietaControlador controlador;

  @override
  State<_DialogoDieta> createState() => _DialogoDietaState();
}

class _DialogoDietaState extends State<_DialogoDieta> {
  final _tipo = TextEditingController();
  final _alergias = TextEditingController();
  final _indicaciones = TextEditingController();
  bool _rellenado = false;

  @override
  void initState() {
    super.initState();
    unawaited(widget.controlador.cargar());
  }

  @override
  void dispose() {
    _tipo.dispose();
    _alergias.dispose();
    _indicaciones.dispose();
    widget.controlador.dispose();
    super.dispose();
  }

  void _rellenar(Dieta dieta) {
    if (!_rellenado) {
      _rellenado = true;
      _tipo.text = dieta.tipo;
      _alergias.text = dieta.alergias.join(', ');
      _indicaciones.text = dieta.indicaciones;
    }
  }

  Future<void> _guardar() async {
    final navegador = Navigator.of(context);
    final avisos = ScaffoldMessenger.of(context);
    final error = await widget.controlador.guardar(
      tipo: _tipo.text,
      alergias: _alergias.text,
      indicaciones: _indicaciones.text,
    );
    avisos.showSnackBar(SnackBar(content: Text(error ?? 'Dieta guardada.')));
    if (error == null) navegador.pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Dieta de ${widget.controlador.estudiante.nombre}'),
      content: SizedBox(
        width: 560,
        child: VistaCarga<(Dieta, List<CambioDieta>)>(
          controlador: widget.controlador,
          constructor: (context, datos) {
            final (dieta, cambios) = datos;
            _rellenar(dieta);
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _tipo,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de menú',
                      hintText: 'Por ejemplo: Sin gluten, triturado…',
                    ),
                  ),
                  TextField(
                    controller: _alergias,
                    decoration: const InputDecoration(
                      labelText: 'Alergias o intolerancias',
                      hintText: 'Separadas por comas',
                    ),
                  ),
                  TextField(
                    controller: _indicaciones,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Indicaciones para cocina',
                    ),
                  ),
                  const TituloSeccion('Cambios'),
                  if (cambios.isEmpty) const Text('Todavía no hay cambios.'),
                  for (final cambio in cambios)
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.history_rounded),
                      title: Text(cambio.resumen),
                      subtitle: Text(
                        '${FormatoFecha.diaCompleto(cambio.momento)}, '
                        '${FormatoFecha.hora(cambio.momento)}',
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _guardar, child: const Text('Guardar')),
      ],
    );
  }
}

/// Listado diario para cocina (HU-25): solo los nombres de quienes comen y
/// sus dietas. Se puede copiar para enviarlo.
class _DialogoListado extends StatelessWidget {
  const _DialogoListado({required this.listado});

  final ListadoCocina listado;

  @override
  Widget build(BuildContext context) {
    final texto = CalculosComedor.comoTexto(listado);
    return AlertDialog(
      title: Text(
        'Listado de ${listado.nombreAula} · '
        '${FormatoFecha.diaCompleto(listado.fecha)}',
      ),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (listado.sinResponder > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Atención: ${listado.sinResponder} sin responder. '
                    'Revísalo antes de enviarlo.',
                  ),
                ),
              Text(
                'Comensales: ${listado.comensales.length} '
                '(${listado.conDieta} con dieta)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              for (final linea in listado.comensales)
                ListTile(
                  dense: true,
                  title: Text(linea.nombre),
                  subtitle: linea.dieta == null ? null : Text(linea.dieta!),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: () async {
            final avisos = ScaffoldMessenger.of(context);
            await Clipboard.setData(ClipboardData(text: texto));
            avisos.showSnackBar(
              const SnackBar(content: Text('Listado copiado.')),
            );
          },
          icon: const Icon(Icons.copy_rounded),
          label: const Text('Copiar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}
