import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


Future<void> initializeFirebase() async {
    await dotenv.load(fileName: ".env");
    await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: dotenv.env['API_KEY'] ?? '',
      authDomain: dotenv.env['AUTH_DOMAIN'],
      databaseURL: dotenv.env['DATABASE_URL'],
      projectId: dotenv.env['PROJECT_ID'] ?? '',
      storageBucket: dotenv.env['STORAGE_BUCKET'],
      messagingSenderId: dotenv.env['MESSAGING_SENDER_ID'] ?? '',
      appId: dotenv.env['APP_ID'] ?? '',
      measurementId: dotenv.env['MEASUREMENT_ID'],
    ),
  );
}