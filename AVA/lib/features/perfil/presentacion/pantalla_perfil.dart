import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constantes/dimensiones.dart';
import '../../../core/constantes/pictogramas.dart';
import '../../../core/tema/ajustes_interfaz.dart';
import '../../../core/utilidades/controlador_carga.dart';
import '../../../core/widgets/avatar_usuario.dart';
import '../../../core/widgets/boton_accesible.dart';
import '../../../core/widgets/cuadricula_ajustada.dart';
import '../../../core/widgets/mensaje_informativo.dart';
import '../../../core/widgets/pantalla_estudiante.dart';
import '../../autenticacion/logica/sesion_controlador.dart';
import '../dominio/perfil_estudiante.dart';
import '../dominio/preferencias_accesibilidad.dart';
import '../logica/preferencias_controlador.dart';
import 'opciones_preferencias.dart';

/// Perfil del estudiante: su foto, su nombre y botones con pictogramas para
/// cambiar el aspecto de toda la app (HU-15). Solo puede cambiarlos si su
/// tutor se lo permite.
class PantallaPerfil extends StatelessWidget {
  const PantallaPerfil({super.key, required this.estudiante});

  final Estudiante estudiante;

  /// Estado de la opción («Sí», «No», «Elegido») o `null` si no tiene, para
  /// no reservar una línea vacía.
  static String? _estado(
    OpcionPreferencia opcion,
    PreferenciasAccesibilidad preferencias,
  ) {
    final estado = opcion.estado(preferencias);
    return estado.isEmpty ? null : estado;
  }

  Future<void> _aplicar(BuildContext context, OpcionPreferencia opcion) async {
    final preferencias = context.read<PreferenciasControlador>();
    final sesion = context.read<SesionControlador>();
    final ajustes = AjustesInterfaz.of(context);
    final avisos = ScaffoldMessenger.of(context);

    String? mensaje;
    try {
      final actualizado = await preferencias.cambiar(
        opcion.aplicar(preferencias.preferencias),
      );
      if (actualizado != null) sesion.actualizarEstudiante(actualizado);
    } on ArgumentError catch (error) {
      mensaje = '${error.message}';
    } on ErrorConMensaje catch (error) {
      mensaje = error.mensaje;
    }
    if (mensaje != null) {
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
                ? CuadriculaAjustada<OpcionPreferencia>(
                    elementos: opciones,
                    maxColumnas: 5,
                    anchoMinimoCelda: 180,
                    altoMinimoCelda: 130,
                    espaciado: Dimensiones.espaciadoPequeno,
                    permitirPaginas: true,
                    textosDe: (opcion) => (
                      etiqueta: null,
                      texto: opcion.texto,
                      secundario: _estado(opcion, preferencias),
                    ),
                    constructor: (context, opcion) => BotonAccesible(
                      texto: opcion.texto,
                      textoSecundario: _estado(opcion, preferencias),
                      tamanoTexto: CuadriculaAjustada.letraDe(context),
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
