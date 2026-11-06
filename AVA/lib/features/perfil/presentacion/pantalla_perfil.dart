import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constantes/dimensiones.dart';
import '../../../core/constantes/pictogramas.dart';
import '../../../core/tema/ajustes_interfaz.dart';
import '../../../core/widgets/avatar_usuario.dart';
import '../../../core/widgets/boton_accesible.dart';
import '../../../core/widgets/cuadricula_paginada.dart';
import '../../../core/widgets/mensaje_informativo.dart';
import '../../../core/widgets/pantalla_estudiante.dart';
import '../../autenticacion/logica/sesion_controlador.dart';
import '../dominio/estudiante.dart';
import '../logica/preferencias_controlador.dart';
import 'opciones_preferencias.dart';

/// Perfil del estudiante: su foto, su nombre y botones con pictogramas para
/// cambiar el aspecto de toda la app (HU-14). Solo puede cambiarlos si su
/// tutor se lo permite.
class PantallaPerfil extends StatelessWidget {
  const PantallaPerfil({super.key, required this.estudiante});

  final Estudiante estudiante;

  Future<void> _aplicar(BuildContext context, OpcionPreferencia opcion) async {
    final preferencias = context.read<PreferenciasControlador>();
    final sesion = context.read<SesionControlador>();
    final ajustes = AjustesInterfaz.of(context);
    final avisos = ScaffoldMessenger.of(context);

    try {
      final actualizado = await preferencias.cambiar(
        opcion.aplicar(preferencias.preferencias),
      );
      if (actualizado != null) sesion.actualizarEstudiante(actualizado);
    } on ArgumentError catch (error) {
      final mensaje = '${error.message}';
      if (ajustes.leerEnVoz) await ajustes.voz.decir(mensaje);
      avisos.showSnackBar(SnackBar(content: Text(mensaje)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final preferencias = context.watch<PreferenciasControlador>().preferencias;
    final opciones = OpcionPreferencia.todas();

    return PantallaEstudiante(
      titulo: 'Mi perfil',
      pictograma: Pictogramas.perfil,
      icono: Icons.person_rounded,
      color: estudiante.color,
      textoVoz: estudiante.puedeModificarPreferencias
          ? 'Mi perfil. Toca un botón para cambiar cómo ves la agenda.'
          : 'Mi perfil. Tu profesor elige cómo ves la agenda.',
      cuerpo: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 220,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                children: [
                  AvatarUsuario(
                    nombre: estudiante.nombre,
                    imagen: estudiante.avatar,
                    color: estudiante.color,
                    tamano: Dimensiones.avatarGrande,
                  ),
                  const SizedBox(height: Dimensiones.espaciadoPequeno),
                  Text(
                    estudiante.nombre,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: Dimensiones.espaciado),
          Expanded(
            child: estudiante.puedeModificarPreferencias
                ? CuadriculaPaginada<OpcionPreferencia>(
                    elementos: opciones,
                    maxColumnas: 4,
                    anchoMinimoCelda: 180,
                    altoMinimoCelda: 170,
                    espaciado: Dimensiones.espaciadoPequeno,
                    constructor: (context, opcion) => BotonAccesible(
                      texto: opcion.texto,
                      textoSecundario: opcion.estado(preferencias),
                      pictograma: opcion.pictograma,
                      icono: opcion.icono,
                      color: opcion.color,
                      seleccionado: opcion.activa(preferencias),
                      alPulsar: () => _aplicar(context, opcion),
                    ),
                  )
                : const MensajeInformativo(
                    icono: Icons.school_rounded,
                    pictograma: Pictogramas.maestro,
                    texto: 'Tu profesor elige cómo ves la agenda.',
                  ),
          ),
        ],
      ),
    );
  }
}
