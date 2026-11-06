import '../modelos/recurso_visual.dart';

/// Pictogramas de ARASAAC usados en la interfaz (RNF-04).
///
/// Autor de los pictogramas: Sergio Palao. Origen: ARASAAC
/// (https://arasaac.org). Licencia: CC BY-NC-SA. Propiedad: Gobierno de
/// Aragón (España).
abstract final class Pictogramas {
  // Navegación y acciones.
  static const agenda = PictogramaArasaac(5898);
  static const perfil = PictogramaArasaac(2617);
  static const semana = PictogramaArasaac(7244);
  static const dia = PictogramaArasaac(7022);
  static const ahora = PictogramaArasaac(13026);
  static const despues = PictogramaArasaac(13080);
  static const siguiente = PictogramaArasaac(27331);
  static const ayuda = PictogramaArasaac(12252);
  static const empezar = PictogramaArasaac(5431);
  static const terminar = PictogramaArasaac(5358);
  static const ver = PictogramaArasaac(2474);
  static const escuchar = PictogramaArasaac(2381);
  static const entrar = PictogramaArasaac(2742);
  static const salir = PictogramaArasaac(2806);
  static const borrar = PictogramaArasaac(2286);
  static const lapiz = PictogramaArasaac(2440);
  static const elegir = PictogramaArasaac(6483);
  static const exito = PictogramaArasaac(11599);
  static const aplaudir = PictogramaArasaac(4563);
  static const contento = PictogramaArasaac(3245);
  static const pulsar = PictogramaArasaac(7222);
  static const contrasena = PictogramaArasaac(27691);
  static const numeros = PictogramaArasaac(2879);
  static const hola = PictogramaArasaac(6009);
  static const configuracion = PictogramaArasaac(39466);

  // Personas y lugares.
  static const colegio = PictogramaArasaac(3082);
  static const aula = PictogramaArasaac(5913);
  static const maestro = PictogramaArasaac(2457);
  static const alumno = PictogramaArasaac(5900);
  static const persona = PictogramaArasaac(34559);
  static const familia = PictogramaArasaac(2392);
  static const casa = PictogramaArasaac(2317);
  static const calendario = PictogramaArasaac(3071);
  static const reloj = PictogramaArasaac(2549);

  // Momentos del día.
  static const manana = PictogramaArasaac(7152);
  static const mediodia = PictogramaArasaac(32708);
  static const tarde = PictogramaArasaac(7268);
  static const noche = PictogramaArasaac(7181);

  // Preferencias de accesibilidad.
  static const letra = PictogramaArasaac(39235);
  static const grande = PictogramaArasaac(4658);
  static const pequeno = PictogramaArasaac(4716);
  static const colores = PictogramaArasaac(5968);
  static const contraste = PictogramaArasaac(4710);
  static const luz = PictogramaArasaac(8619);
  static const ojo = PictogramaArasaac(6573);

  // Actividades.
  static const asamblea = PictogramaArasaac(27574);
  static const recreo = PictogramaArasaac(6204);
  static const comer = PictogramaArasaac(2349);
  static const cocinar = PictogramaArasaac(2342);
  static const huerto = PictogramaArasaac(2974);
  static const ordenador = PictogramaArasaac(2487);
  static const lavadora = PictogramaArasaac(2442);
  static const manualidades = PictogramaArasaac(7794);
  static const fotocopiadora = PictogramaArasaac(8586);
  static const correo = PictogramaArasaac(3086);
  static const regar = PictogramaArasaac(2816);
  static const ponerLaMesa = PictogramaArasaac(5549);
  static const ordenar = PictogramaArasaac(2872);
  static const hacerLaCama = PictogramaArasaac(5481);
  static const pasear = PictogramaArasaac(8649);
  static const jugar = PictogramaArasaac(2439);
  static const leer = PictogramaArasaac(7141);
  static const musica = PictogramaArasaac(11311);
  static const deporte = PictogramaArasaac(7010);
  static const television = PictogramaArasaac(25498);
  static const descansar = PictogramaArasaac(3299);
  static const dormir = PictogramaArasaac(2369);
  static const desayunar = PictogramaArasaac(4625);
  static const mochila = PictogramaArasaac(2475);
  static const biblioteca = PictogramaArasaac(3065);
  static const taller = PictogramaArasaac(6225);
  static const gimnasio = PictogramaArasaac(6005);
  static const autobus = PictogramaArasaac(2262);
  static const cine = PictogramaArasaac(4602);

  // Claves de acceso con pictogramas.
  static const sol = PictogramaArasaac(2798);
  static const manzana = PictogramaArasaac(2462);
  static const mariposa = PictogramaArasaac(2465);
  static const perro = PictogramaArasaac(7202);
  static const flor = PictogramaArasaac(3102);
  static const coche = PictogramaArasaac(2339);

  /// Días de la semana, de lunes a domingo.
  static const diasSemana = [
    PictogramaArasaac(6554),
    PictogramaArasaac(6557),
    PictogramaArasaac(6563),
    PictogramaArasaac(6536),
    PictogramaArasaac(6629),
    PictogramaArasaac(6605),
    PictogramaArasaac(6478),
  ];

  /// Texto de atribución obligatorio por la licencia de ARASAAC (RNF-12).
  static const atribucion =
      'Pictogramas: Sergio Palao. Origen: ARASAAC (arasaac.org). '
      'Licencia: CC BY-NC-SA. Propiedad: Gobierno de Aragón (España).';
}
