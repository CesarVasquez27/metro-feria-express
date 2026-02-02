import 'package:flutter/material.dart';
import 'package:metro_feria/services/auth_service.dart';
// IMPORTANTE: Importamos el Home para poder navegar hacia él
import 'package:metro_feria/features/home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Estos controladores son como "variables" que guardan lo que escribes en las cajas de texto
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  // _isLogin: true si estamos logueando, false si nos estamos registrando
  bool _isLogin = true;
  // _isLoading: para mostrar el circulito girando mientras Firebase piensa
  bool _isLoading = false;

  // Esta es la función principal que se activa al tocar el botón naranja
  void _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // 1. VALIDACIÓN BÁSICA: Que no estén vacíos
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor llena todos los campos')),
      );
      return;
    }

    // 2. REGLA DE NEGOCIO: Solo correos Unimet
    if (!email.endsWith('@unimet.edu.ve')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solo se permiten correos @unimet.edu.ve'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Activamos el circulito de carga
    setState(() => _isLoading = true);

    // Llamamos al servicio de Firebase (Login o Registro)
    String? error;
    if (_isLogin) {
      error = await _authService.loginUser(email, password);
    } else {
      error = await _authService.registerUser(email, password);
    }

    // Desactivamos el circulito de carga
    setState(() => _isLoading = false);

    if (!mounted) return; // Seguridad de Flutter

    if (error != null) {
      // SI HUBO ERROR: Lo mostramos en rojo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    } else {
      // SI FUE EXITOSO: Navegamos al Home
      // pushReplacement significa que borramos el Login del historial (para que no puedan volver atrás)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Center y SingleChildScrollView sirven para que se vea bien en cualquier tamaño de pantalla
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ICONO Y TÍTULO
              const Icon(Icons.storefront, size: 80, color: Colors.orange),
              const SizedBox(height: 20),
              const Text(
                "MetroFeria Express",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              // CAMPO EMAIL
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Correo Unimet",
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // CAMPO CONTRASEÑA
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: "Contraseña",
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                obscureText: true, // Oculta la contraseña con puntitos
              ),
              const SizedBox(height: 30),

              // BOTÓN PRINCIPAL (INGRESAR / REGISTRARSE)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _isLogin ? "INGRESAR" : "REGISTRARSE",
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // TEXTO PARA CAMBIAR ENTRE LOGIN Y REGISTRO
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                },
                child: Text(
                  _isLogin
                      ? "¿No tienes cuenta? Regístrate aquí"
                      : "¿Ya tienes cuenta? Inicia sesión",
                  style: const TextStyle(color: Colors.brown),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
