// EJEMPLO de lib/firebase_options.dart
// Copiá este archivo como firebase_options.dart y completá con tus credenciales.
// Para obtenerlas: console.firebase.google.com → tu proyecto → ⚙️ → Web app

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static const FirebaseOptions currentPlatform = FirebaseOptions(
    apiKey: 'TU_API_KEY',
    appId: 'TU_APP_ID',
    messagingSenderId: 'TU_SENDER_ID',
    projectId: 'TU_PROJECT_ID',
    authDomain: 'TU_AUTH_DOMAIN',
    storageBucket: 'TU_STORAGE_BUCKET',
    measurementId: 'TU_MEASUREMENT_ID',
  );
}
