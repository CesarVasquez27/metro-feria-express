import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // El archivo que generó el comando configure
// Importamos la pantalla de Login usando la ruta segura
import 'package:metro_feria/features/auth/login_screen.dart';

void main() async {
  // 1. Aseguramos que el motor de Flutter esté listo antes de llamar a código nativo
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializamos Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Arrancamos la App
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Quita la etiqueta "Debug"
      title: 'MetroFeria Express',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange), // Color de la marca
        useMaterial3: true,
      ),
      // Aquí definimos que la primera pantalla sea el Login
      home: const LoginScreen(),
    );
  }
}