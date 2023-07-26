import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Duration get loginTime => const Duration(milliseconds: 2250);
  
  Future<String?> _authUser(LoginData data) async {
    debugPrint('Name: ${data.name}, Password: ${data.password}');
    if (!_isValidEmail(data.name)) {
      return 'Invalid email format';
    }

    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: data.name,
        password: data.password,
      );
      final User? user = userCredential.user;
      if (user == null) {
        return 'User not exists';
      }
    } catch (e) {
      return 'Invalid email or password';
    }
    return null;
  }

  bool _isValidEmail(String email) {
    // Validasi format email sederhana menggunakan regular expression
    // Silakan gunakan metode validasi yang lebih canggih jika diperlukan
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  Future<String?> _signupUser(SignupData data) async {
    debugPrint('Signup Name: ${data.name}, Password: ${data.password}');
    if (!_isValidEmail(data.name ?? '')) {
      return 'Invalid email format';
    }

    final password = data.password ?? '';
    if (!_isStrongPassword(password)) {
      return 'Password must contain at least one uppercase letter and one special character';
    }

    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: data.name ?? '',
        password: password,
      );
      // ignore: unused_local_variable
      final User? user = userCredential.user;
      // Additional logic for user registration (if needed)
    } catch (e) {
      return 'Error registering user';
    }
    return null;
  }

  bool _isStrongPassword(String password) {
    // Password must contain at least one uppercase letter and one special character
    final uppercaseRegex = RegExp(r'[A-Z]');
    final specialCharRegex = RegExp(r'[!@#\$%^&*(),.?":{}|<>]');
    return uppercaseRegex.hasMatch(password) &&
        specialCharRegex.hasMatch(password);
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
    title: 'MOBILKU',
    theme: LoginTheme(
      primaryColor: const Color(0xFF2196F3),
    ),
    onLogin: _authUser,
    onSignup: _signupUser,
    onSubmitAnimationCompleted: () {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    },
    onRecoverPassword: (_) async {
      await Future.delayed(loginTime);
      return 'Password recovery not implemented.';
    },
  );
  }
}
