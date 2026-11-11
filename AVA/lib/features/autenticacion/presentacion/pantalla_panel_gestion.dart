import 'package:flutter/material.dart';

import '../../../app/rutas.dart';
import '../../../core/constantes/dimensiones.dart';
import '../../../core/constantes/paleta.dart';
import '../../../core/constantes/pictogramas.dart';
import '../../../core/modelos/recurso_visual.dart';
import '../../../core/widgets/atribucion_arasaac.dart';
import '../../../core/widgets/boton_accesible.dart';
import '../../../core/widgets/cuadricula_ajustada.dart';
import '../dominio/cuenta.dart';
import '../logica/permisos.dart';
import 'widgets/boton_cerrar_sesion.dart';

/// Pantalla principal de tutores y administración. Muestra solo las
/// funciones permitidas para el rol de la cuenta (HU-03).
class PantallaPanelGestion extends StatelessWidget {
  const PantallaPanelGestion({super.key, required this.cuenta});

  final Cuenta cuenta;

  @override
  Widget build(BuildContext context) {
    final opciones = <_OpcionPanel>[
      _OpcionPanel(
        Permisos.esAdministrador(cuenta) ? 'Alumnos' : 'Mis alumnos',
        'Perfil, accesibilidad, acceso y tareas',
        Pictogramas.alumno,
        Icons.groups_rounded,
        ColorPastel.cielo,
        Rutas.listaAlumnos,
      ),
      if (Permisos.puedeCrearEncargos(cuenta))
        const _OpcionPanel(
          'Encargos del colegio',
          'Asignar un encargo a alumnos o a un aula',
          Pictogramas.colegio,
          Icons.assignment_rounded,
          ColorPastel.menta,
          Rutas.encargos,
        ),
      if (Permisos.puedeGestionarAulas(cuenta))
        const _OpcionPanel(
          'Aulas',
          'Crear aulas y asignar alumnos y tutor',
          Pictogramas.aula,
          Icons.meeting_room_rounded,
          ColorPastel.amarillo,
          Rutas.gestionAulas,
        ),
      if (Permisos.puedeGestionarCuentas(cuenta))
        const _OpcionPanel(
          'Cuentas',
          'Crear y editar cuentas y roles',
          Pictogramas.persona,
          Icons.manage_accounts_rounded,
          ColorPastel.lavanda,
          Rutas.cuentas,
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Hola, ${cuenta.nombre}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Chip(
              avatar: const Icon(Icons.badge_rounded),
              label: Text(cuenta.rol.nombre),
            ),
          ),
          const BotonCerrarSesion(),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Dimensiones.espaciado),
          child: Column(
            children: [
              Expanded(
                child: CuadriculaAjustada<_OpcionPanel>(
                  elementos: opciones,
                  maxColumnas: 2,
                  anchoMinimoCelda: 320,
                  altoMinimoCelda: 160,
                  altoMaximoCelda: 240,
                  constructor: (context, opcion) => BotonAccesible(
                    texto: opcion.texto,
                    textoSecundario: opcion.descripcion,
                    pictograma: opcion.pictograma,
                    icono: opcion.icono,
                    color: opcion.color,
                    disposicion: DisposicionBoton.horizontal,
                    alPulsar: () => Navigator.pushNamed(context, opcion.ruta),
                  ),
                ),
              ),
              const SizedBox(height: Dimensiones.espaciadoPequeno),
              const AtribucionArasaac(),
            ],
          ),
        ),
      ),
    );
  }
}

class _OpcionPanel {
  const _OpcionPanel(
    this.texto,
    this.descripcion,
    this.pictograma,
    this.icono,
    this.color,
    this.ruta,
  );

  final String texto;
  final String descripcion;
  final RecursoVisual pictograma;
  final IconData icono;
  final ColorPastel color;
  final String ruta;
}
