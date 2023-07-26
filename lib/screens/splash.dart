import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    _initializeSplashScreen();
  }

  _initializeSplashScreen() async {
    // Display the splash screen for 5 seconds
    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

    await Future.delayed(const Duration(seconds: 5));
    FlutterNativeSplash.remove();

    // Navigate to the main screen after the delay
    // ignore: use_build_context_synchronously
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    // Display the splash screen content here (e.g., logo, loading animation)
    return const Scaffold(
      body: Center(
        child:
            CircularProgressIndicator(), // Placeholder for splash screen content
      ),
    );
  }
}
