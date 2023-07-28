import 'package:app_mobil/dotenv_firebase_options.dart';
import 'package:app_mobil/screens/home.dart';
import 'package:app_mobil/screens/login.dart';
import 'package:app_mobil/screens/splash.dart';
import 'package:flutter/material.dart';


void main() async {
  // TRY THIS: Try uncommenting the line below to see the splash screen

  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Mobilku',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2196F3)),
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MyHomePage(title: "App Mobilku"),
        // Add more routes for other screens if needed
      },
    );
  }
}
