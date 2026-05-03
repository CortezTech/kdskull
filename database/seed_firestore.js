const admin = require("firebase-admin");

// Opcion A: usar variable de entorno GOOGLE_APPLICATION_CREDENTIALS.
// Opcion B: descomenta y ajusta la ruta del JSON de service account.
// const serviceAccount = require("./serviceAccountKey.json");

if (!admin.apps.length) {
  admin.initializeApp({
    // credential: admin.credential.cert(serviceAccount),
    credential: admin.credential.applicationDefault()
  });
}

const db = admin.firestore();

const platos = [
  { name: "Pollo al horno", category: "Principal", available: true, stationId: "SuCv7k4oQZbLPJ0N1CHi", stdPrepTimeSec: 900 },
  { name: "Tarta de queso", category: "Postres", available: true, stationId: "nKR7BDDaJHWVq7crMYar", stdPrepTimeSec: 240 },
  { name: "Ensalada mixta", category: "Entrantes", available: true, stationId: "nKR7BDDaJHWVq7crMYar", stdPrepTimeSec: 180 },
  { name: "Helado", category: "Postres", available: true, stationId: "nKR7BDDaJHWVq7crMYar", stdPrepTimeSec: 120 },
  { name: "Bocadillo caliente", category: "Principal", available: true, stationId: "96g3wWUBdKmEPBh1nPlZ", stdPrepTimeSec: 420 },
  { name: "Gazpacho", category: "Entrantes", available: true, stationId: "nKR7BDDaJHWVq7crMYar", stdPrepTimeSec: 240 },
  { name: "Pechuga de pollo a la plancha", category: "Principal", available: true, stationId: "96g3wWUBdKmEPBh1nPlZ", stdPrepTimeSec: 720 },
  { name: "Pan de ajo", category: "Entrantes", available: true, stationId: "SuCv7k4oQZbLPJ0N1CHi", stdPrepTimeSec: 360 },
  { name: "Lasana", category: "Principal", available: false, stationId: "SuCv7k4oQZbLPJ0N1CHi", stdPrepTimeSec: 1080 },
  { name: "Verduras salteadas", category: "Entrantes", available: true, stationId: "96g3wWUBdKmEPBh1nPlZ", stdPrepTimeSec: 480 },
  { name: "Hamburguesa", category: "Principal", available: true, stationId: "96g3wWUBdKmEPBh1nPlZ", stdPrepTimeSec: 600 },
  { name: "Pizza margarita", category: "Principal", available: true, stationId: "SuCv7k4oQZbLPJ0N1CHi", stdPrepTimeSec: 1200 },
  { name: "Prueba 86", category: "Otros", available: false, stationId: "96g3wWUBdKmEPBh1nPlZ", stdPrepTimeSec: 12 }
];

async function seed() {
  console.log("Iniciando seed de Firestore (platos)...");

  const batch = db.batch();
  const now = admin.firestore.FieldValue.serverTimestamp();

  for (const plato of platos) {
    const ref = db.collection("dishes").doc();
    batch.set(ref, {
      ...plato,
      createdAt: now,
      updatedAt: now
    });
  }

  await batch.commit();
  console.log("Seed completado correctamente.");
  console.log(`Documentos insertados en 'dishes': ${platos.length}`);
}

seed()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Error ejecutando seed:", error);
    process.exit(1);
  });
