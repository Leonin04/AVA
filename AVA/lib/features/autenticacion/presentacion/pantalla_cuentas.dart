import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constantes/dimensiones.dart';
import '../../../core/widgets/pantalla_gestion.dart';
import '../../../core/widgets/vista_carga.dart';
import '../../aulas/dominio/aula.dart';
import '../../aulas/dominio/repositorio_aulas.dart';
import '../../perfil/dominio/repositorio_estudiantes.dart';
import '../dominio/clave_acceso.dart';
import '../dominio/cuenta.dart';
import '../dominio/repositorio_autenticacion.dart';
import '../dominio/repositorio_cuentas.dart';
import '../dominio/rol.dart';
import '../logica/gestion_cuentas_controlador.dart';
import 'widgets/aviso_error.dart';
import 'widgets/editor_clave.dart';

/// Lista de cuentas con su rol, para crearlas y editarlas (HU-01, HU-02).
/// Solo para la administración.
class PantallaCuentas extends StatefulWidget {
  const PantallaCuentas({super.key});

  @override
  State<PantallaCuentas> createState() => _PantallaCuentasState();
}

class _PantallaCuentasState extends State<PantallaCuentas> {
  late final GestionCuentasControlador _controlador;

  @override
  void initState() {
    super.initState();
    _controlador = GestionCuentasControlador(
      cuentas: context.read<RepositorioCuentas>(),
      autenticacion: context.read<RepositorioAutenticacion>(),
      estudiantes: context.read<RepositorioEstudiantes>(),
      aulas: context.read<RepositorioAulas>(),
    );
    unawaited(_controlador.cargar());
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  Future<void> _abrirFormulario([Cuenta? cuenta]) async {
    final aulas = await _controlador.aulas();
    if (!mounted) return;
    final guardada = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog.fullscreen(
        child: _FormularioCuenta(
          controlador: _controlador,
          cuenta: cuenta,
          aulas: aulas,
        ),
      ),
    );
    if (guardada == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cuenta guardada.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PantallaGestion(
      titulo: 'Cuentas',
      desplazable: false,
      botonFlotante: FloatingActionButton.extended(
        onPressed: _abrirFormulario,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Nueva cuenta'),
      ),
      cuerpo: VistaCarga<List<Cuenta>>(
        controlador: _controlador,
        constructor: (context, cuentas) => ListView.separated(
          padding: const EdgeInsets.only(bottom: 96),
          itemCount: cuentas.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final cuenta = cuentas[i];
            return Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                leading: Icon(_icono(cuenta.rol), size: 36),
                title: Text(
                  cuenta.nombre,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  'Usuario: ${cuenta.id}'
                  '${cuenta.email == null ? '' : ' · ${cuenta.email}'}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Chip(label: Text(cuenta.rol.nombre)),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Editar ${cuenta.nombre}',
                      onPressed: () => _abrirFormulario(cuenta),
                      icon: const Icon(Icons.edit_rounded),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static IconData _icono(Rol rol) => switch (rol) {
    Rol.administrador => Icons.admin_panel_settings_rounded,
    Rol.tutor => Icons.school_rounded,
    Rol.estudiante => Icons.face_rounded,
  };
}

class _FormularioCuenta extends StatefulWidget {
  const _FormularioCuenta({
    required this.controlador,
    required this.cuenta,
    required this.aulas,
  });

  final GestionCuentasControlador controlador;
  final Cuenta? cuenta;
  final List<Aula> aulas;

  @override
  State<_FormularioCuenta> createState() => _FormularioCuentaState();
}

class _FormularioCuentaState extends State<_FormularioCuenta> {
  final _formulario = GlobalKey<FormState>();
  late final _usuario = TextEditingController(text: widget.cuenta?.id);
  late final _nombre = TextEditingController(text: widget.cuenta?.nombre);
  late final _email = TextEditingController(text: widget.cuenta?.email);
  final _contrasena = TextEditingController();
  late Rol _rol = widget.cuenta?.rol ?? Rol.tutor;
  String? _idAula;
  ClaveAcceso? _claveEstudiante;
  String? _error;
  bool _guardando = false;

  bool get _esNueva => widget.cuenta == null;

  @override
  void dispose() {
    _usuario.dispose();
    _nombre.dispose();
    _email.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  /// Roles que se pueden elegir. Una cuenta de estudiante no cambia de rol,
  /// porque tiene un perfil y una agenda asociados; las de gestión pueden
  /// pasar de tutor a administrador y al revés.
  List<Rol> get _rolesPosibles {
    final cuenta = widget.cuenta;
    if (cuenta == null) return Rol.values;
    if (cuenta.rol == Rol.estudiante) return const [Rol.estudiante];
    return const [Rol.administrador, Rol.tutor];
  }

  Future<void> _guardar() async {
    if (!(_formulario.currentState?.validate() ?? false)) return;

    final clave = _rol == Rol.estudiante
        ? _claveEstudiante
        : (_contrasena.text.isEmpty ? null : ClaveContrasena(_contrasena.text));
    if (_esNueva && clave == null) {
      setState(
        () => _error = _rol == Rol.estudiante
            ? 'Elige la clave de acceso del alumno.'
            : 'Escribe una contraseña.',
      );
      return;
    }

    setState(() {
      _guardando = true;
      _error = null;
    });
    final cuenta = Cuenta(
      id: _usuario.text.trim(),
      nombre: _nombre.text.trim(),
      rol: _rol,
      email: _email.text.trim().isEmpty ? null : _email.text.trim(),
    );

    String? error;
    if (_esNueva) {
      error = await widget.controlador.crear(
        cuenta: cuenta,
        clave: clave!,
        idAula: _idAula,
      );
    } else {
      await widget.controlador.actualizar(cuenta, nuevaClave: clave);
    }
    if (!mounted) return;
    setState(() {
      _guardando = false;
      _error = error;
    });
    if (error == null) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controlador;

    return Scaffold(
      appBar: AppBar(
        title: Text(_esNueva ? 'Nueva cuenta' : 'Editar cuenta'),
        leading: IconButton(
          tooltip: 'Cerrar sin guardar',
          onPressed: () => Navigator.of(context).pop(false),
          icon: const Icon(Icons.close_rounded),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: _guardando ? null : _guardar,
              icon: const Icon(Icons.save_rounded),
              label: const Text('Guardar'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Dimensiones.espaciado),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Form(
              key: _formulario,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const TituloSeccion('Rol'),
                  SegmentedButton<Rol>(
                    segments: [
                      for (final rol in _rolesPosibles)
                        ButtonSegment(value: rol, label: Text(rol.nombre)),
                    ],
                    selected: {_rol},
                    onSelectionChanged: (s) => setState(() => _rol = s.first),
                  ),
                  const TituloSeccion('Datos'),
                  TextFormField(
                    controller: _usuario,
                    enabled: _esNueva,
                    decoration: const InputDecoration(
                      labelText: 'Usuario (no se puede cambiar después)',
                    ),
                    validator: c.validarUsuario,
                  ),
                  const SizedBox(height: Dimensiones.espaciado),
                  TextFormField(
                    controller: _nombre,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    validator: c.validarNombre,
                  ),
                  if (_rol != Rol.estudiante) ...[
                    const SizedBox(height: Dimensiones.espaciado),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Correo'),
                      validator: (v) => c.validarEmail(v, rol: _rol),
                    ),
                    const SizedBox(height: Dimensiones.espaciado),
                    TextFormField(
                      controller: _contrasena,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: _esNueva
                            ? 'Contraseña'
                            : 'Contraseña nueva (vacía para no cambiarla)',
                      ),
                      validator: (v) =>
                          c.validarContrasena(v, obligatoria: _esNueva),
                    ),
                  ],
                  if (_rol == Rol.estudiante && _esNueva) ...[
                    const TituloSeccion('Aula'),
                    DropdownButtonFormField<String?>(
                      initialValue: _idAula,
                      decoration: const InputDecoration(labelText: 'Aula'),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Sin aula'),
                        ),
                        for (final aula in widget.aulas)
                          DropdownMenuItem(
                            value: aula.id,
                            child: Text(aula.nombre),
                          ),
                      ],
                      onChanged: (id) => setState(() => _idAula = id),
                    ),
                  ],
                  if (_rol == Rol.estudiante) ...[
                    TituloSeccion(
                      'Clave de acceso',
                      descripcion: _esNueva
                          ? null
                          : 'Déjala vacía para no cambiarla. También se '
                                'puede cambiar desde la ficha del alumno.',
                    ),
                    EditorClave(alCambiar: (clave) => _claveEstudiante = clave),
                  ],
                  if (_error case final mensaje?) ...[
                    const SizedBox(height: Dimensiones.espaciado),
                    AvisoError(mensaje: mensaje),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
