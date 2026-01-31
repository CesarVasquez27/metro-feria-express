import 'package:flutter/material.dart';
import 'package:metro_feria/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService(); // Instancia de nuestro servicio
  bool _isLogin = true; // Para alternar entre "Login" y "Registro"
  bool _isLoading = false;

  void _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // 1. Validación de campos vacíos
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor llena todos los campos')),
      );
      return;
    }

    // 2. CRITERIO DE ACEPTACIÓN: Validar correo UNIMET
    if (!email.endsWith('@unimet.edu.ve')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🛑 Solo se permiten correos @unimet.edu.ve'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    String? error;
    if (_isLogin) {
      // Iniciar Sesión
      error = await _authService.loginUser(email, password);
    } else {
      // Registrarse
      error = await _authService.registerUser(email, password);
    }

    setState(() => _isLoading = false);

    if (error != null) {
      // Hubo error (ej. contraseña corta)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    } else {
      // ÉXITO: Aquí navegaremos al Home (próximo paso)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isLogin ? '¡Bienvenido!' : '¡Cuenta creada con éxito!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.storefront, size: 80, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              "MetroFeria Express",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Correo Unimet",
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Contraseña",
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      _isLogin ? "INGRESAR" : "REGISTRARSE",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => setState(() => _isLogin = !_isLogin),
              child: Text(
                _isLogin
                    ? "¿No tienes cuenta? Regístrate aquí"
                    : "¿Ya tienes cuenta? Inicia sesión",
              ),
            ),
          ],
        ),
      ),
    );
  }
}