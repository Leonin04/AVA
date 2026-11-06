// Carga datos de ejemplo en la base de datos de la Agenda accesible.
//
// Por defecto SOLO funciona contra el emulador local de Firebase.
// Uso:
//   1) En la raíz del repositorio: firebase emulators:start
//   2) En otra terminal, en database/seed: npm install && npm run seed
//
// Todos los datos son inventados. No usar datos reales del alumnado.

const admin = require('firebase-admin');

process.env.FIRESTORE_EMULATOR_HOST ??= '127.0.0.1:8080';
process.env.FIREBASE_AUTH_EMULATOR_HOST ??= '127.0.0.1:9099';

admin.initializeApp({ projectId: process.env.GCLOUD_PROJECT || 'demo-agenda' });
const db = admin.firestore();
const auth = admin.auth();

// Dominio interno para las cuentas de los estudiantes (no reciben correos).
const DOMINIO_EST = 'alumnos.agenda.local';

async function crearCuenta(email, password, nombre) {
  try {
    const u = await auth.getUserByEmail(email);
    return u.uid;
  } catch {
    const u = await auth.createUser({ email, password, displayName: nombre });
    return u.uid;
  }
}

function preferenciasPorDefecto() {
  return {
    comunicacion: {
      pictogramas: true,
      imagenes: true,
      texto: true,
      sonido: false,
      voz: true,
      botonesGrandes: true,
    },
    visual: {
      colores: 'alto_contraste',     // alto_contraste | claro | oscuro
      tipografia: 'Atkinson Hyperlegible',
      tamanoLetra: 22,               // puntos
      posicionMenus: 'abajo',        // arriba | abajo
      posicionBotones: 'derecha',    // izquierda | derecha
    },
  };
}

async function main() {
  const ahora = admin.firestore.FieldValue.serverTimestamp();

  // ---------- usuarios (admin y tutores) ----------
  const adminUid = await crearCuenta('admin@agenda.test', 'admin123', 'Administración');
  const tutorUid = await crearCuenta('tutor.centro@agenda.test', 'tutor123', 'Laura Martín');
  const famUid = await crearCuenta('familia.ruiz@agenda.test', 'familia123', 'Antonio Ruiz');

  await db.doc(`usuarios/${adminUid}`).set({
    nombre: 'Administración', email: 'admin@agenda.test', rol: 'admin', tipoTutor: null, creadoEn: ahora,
  });
  await db.doc(`usuarios/${tutorUid}`).set({
    nombre: 'Laura Martín', email: 'tutor.centro@agenda.test', rol: 'tutor', tipoTutor: 'centro', creadoEn: ahora,
  });
  await db.doc(`usuarios/${famUid}`).set({
    nombre: 'Antonio Ruiz', email: 'familia.ruiz@agenda.test', rol: 'tutor', tipoTutor: 'familiar', creadoEn: ahora,
  });

  // ---------- aulas ----------
  await db.doc('aulas/aula-ptval-1').set({
    nombre: 'PTVAL 1', tutorResponsable: tutorUid, creadoEn: ahora,
  });

  // ---------- estudiantes ----------
  // El PIN o la secuencia de pictogramas es la contraseña de Authentication:
  // NO se guarda en Firestore.
  const est1 = await crearCuenta(`pablo.r@${DOMINIO_EST}`, '1234-pin', 'Pablo R.');
  const est2 = await crearCuenta(`marta.g@${DOMINIO_EST}`, 'sol-casa-perro', 'Marta G.');

  await db.doc(`estudiantes/${est1}`).set({
    nombre: 'Pablo R.',
    usuario: 'pablo.r',
    lugarResidencia: 'Granada',
    fotoUrl: '',
    queLeCalma: 'Escuchar música con cascos y que le avisen antes de los cambios.',
    queNecesita: 'Instrucciones cortas, de una en una, con pictograma.',
    metodoLogin: 'pin',              // pin | pictograma | contrasena
    aulaId: 'aula-ptval-1',
    tutores: [tutorUid, famUid],
    preferencias: preferenciasPorDefecto(),
    creadoEn: ahora,
  });
  await db.doc(`estudiantes/${est2}`).set({
    nombre: 'Marta G.',
    usuario: 'marta.g',
    lugarResidencia: 'Armilla',
    fotoUrl: '',
    queLeCalma: 'Un rincón tranquilo y respirar contando hasta cinco.',
    queNecesita: 'Letra grande y que se le lea el texto en voz alta.',
    metodoLogin: 'pictograma',
    aulaId: 'aula-ptval-1',
    tutores: [tutorUid],
    preferencias: {
      ...preferenciasPorDefecto(),
      visual: { ...preferenciasPorDefecto().visual, tamanoLetra: 28, colores: 'claro' },
    },
    creadoEn: ahora,
  });

  // ---------- tareas y pasos ----------
  const t1 = db.doc('tareas/ejemplo-reprografia');
  await t1.set({
    nombre: 'Llevar fotocopias a reprografía',
    pictogramaUrl: '',               // URL de ARASAAC: https://static.arasaac.org/pictograms/<id>/<id>_300.png
    descripcion: 'Recoger las fotocopias en el aula y llevarlas a reprografía.',
    tipo: 'colegio',                 // colegio | personal
    horaInicio: '10:00',
    horaFin: '10:20',
    diasSemana: [1, 3],              // 1 = lunes ... 7 = domingo
    creadaPor: tutorUid,
    estudiantes: [est1],
    creadoEn: ahora,
  });
  const pasos1 = [
    'Coger las fotocopias de la mesa de la profesora',
    'Bajar por la escalera a la planta baja',
    'Entregar las fotocopias en reprografía',
    'Volver al aula',
  ];
  for (const [i, texto] of pasos1.entries()) {
    await t1.collection('pasos').doc(`paso-${i + 1}`).set({ orden: i + 1, texto, imagenUrl: '' });
  }

  const t2 = db.doc('tareas/ejemplo-mochila');
  await t2.set({
    nombre: 'Preparar la mochila',
    pictogramaUrl: '',
    descripcion: 'Meter en la mochila lo necesario para el día siguiente.',
    tipo: 'personal',
    horaInicio: '20:00',
    horaFin: '20:15',
    diasSemana: [1, 2, 3, 4, 7],
    creadaPor: famUid,
    estudiantes: [est1, est2],
    creadoEn: ahora,
  });
  const pasos2 = ['Mirar la agenda de mañana', 'Meter los libros', 'Meter el estuche', 'Cerrar la mochila'];
  for (const [i, texto] of pasos2.entries()) {
    await t2.collection('pasos').doc(`paso-${i + 1}`).set({ orden: i + 1, texto, imagenUrl: '' });
  }

  console.log('Datos de ejemplo cargados.');
  console.log({ adminUid, tutorUid, famUid, est1, est2 });
}

main().then(() => process.exit(0)).catch((e) => { console.error(e); process.exit(1); });
