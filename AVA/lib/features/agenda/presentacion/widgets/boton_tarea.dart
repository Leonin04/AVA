import 'package:flutter/material.dart';

import '../../../../core/utilidades/formato_fecha.dart';
import '../../../../core/utilidades/medida_texto.dart';
import '../../../../core/widgets/boton_accesible.dart';
import '../../../tareas/dominio/tarea_agenda.dart';

/// Marca visual para distinguir la tarea actual y la siguiente (HU-11).
enum DestacadoTarea {
  ninguno(null),
  ahora('AHORA'),
  despues('DESPUÉS');

  const DestacadoTarea(this.etiqueta);

  final String? etiqueta;
}

/// Tarea pulsable: pictograma, nombre, hora y estado, con el color de su
/// tipo. La actual y la siguiente llevan además una etiqueta y un borde
/// más grueso, para no distinguirlas solo por el color.
class BotonTarea extends StatelessWidget {
  const BotonTarea({
    super.key,
    required this.tarea,
    required this.alPulsar,
    this.destacado = DestacadoTarea.ninguno,
    this.disposicion = DisposicionBoton.horizontal,
    this.compacta = false,
    this.tamanoTexto,
  });

  final Tarea tarea;
  final VoidCallback? alPulsar;
  final DestacadoTarea destacado;
  final DisposicionBoton disposicion;

  /// Versión reducida (solo la hora de inicio) para la vista semanal.
  final bool compacta;

  /// Letra común a varias tarjetas (ver [BotonAccesible.tamanoTexto]).
  final double? tamanoTexto;

  /// Textos que muestra la tarjeta, para medirlos antes de pintarla.
  static TextosTarjeta textos(
    Tarea tarea, {
    DestacadoTarea destacado = DestacadoTarea.ninguno,
    bool compacta = false,
  }) {
    final hora = compacta
        ? FormatoFecha.hora(tarea.inicio)
        : FormatoFecha.intervalo(tarea.inicio, tarea.fin);
    final estado = switch (tarea.estado) {
      EstadoTarea.pendiente => '',
      EstadoTarea.enCurso => ' · Haciendo',
      EstadoTarea.completada => ' · ✓ Terminada',
    };
    final terminada = tarea.estado == EstadoTarea.completada;
    final marca = destacado.etiqueta;
    // En la versión compacta la marca va en la línea de la hora: una
    // etiqueta aparte quitaría tanto alto que toda la semana tendría que
    // usar letra más pequeña.
    final String secundario;
    if (!compacta) {
      secundario = '$hora$estado';
    } else if (marca != null) {
      secundario = '${marca[0]}${marca.substring(1).toLowerCase()} · $hora';
    } else {
      secundario = terminada ? '✓ $hora' : hora;
    }
    return (
      etiqueta: compacta ? null : marca,
      texto: tarea.titulo,
      secundario: secundario,
    );
  }

  @override
  Widget build(BuildContext context) {
    final contenido = textos(tarea, destacado: destacado, compacta: compacta);

    return BotonAccesible(
      texto: contenido.texto,
      textoSecundario: contenido.secundario,
      etiqueta: contenido.etiqueta,
      tamanoTexto: tamanoTexto,
      pictograma: tarea.pictograma,
      icono: Icons.event_rounded,
      color: tarea.tipo.color,
      disposicion: disposicion,
      seleccionado: destacado != DestacadoTarea.ninguno,
      etiquetaSemantica: [
        if (destacado.etiqueta != null) destacado.etiqueta!,
        tarea.titulo,
        FormatoFecha.intervaloHablado(tarea.inicio, tarea.fin),
        tarea.estado.nombre,
      ].join('. '),
      textoVoz:
          '${tarea.titulo}, ${FormatoFecha.intervaloHablado(tarea.inicio, tarea.fin)}',
      alPulsar: alPulsar,
    );
  }
}
