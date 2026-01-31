import 'package:flutter/material.dart';
// Imports absolutos para evitar errores de rutas
import 'package:metro_feria/services/auth_service.dart';
import 'package:metro_feria/features/home/home_screen.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para leer lo que escribe el usuario
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Instancia de nuestro servicio de autenticación
  final AuthService _authService = AuthService(); 
  
  // Variables de estado
  bool _isLogin = true; // true = Login, false = Registro
  bool _isLoading = false; // Para mostrar el círculo de carga

  // Función principal que se ejecuta al dar click al botón naranja
  void _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // 1. Validación: Campos vacíos
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor llena todos los campos')),
      );
      return;
    }

    // 2. Validación: Dominio Unimet
    if (!email.endsWith('@unimet.edu.ve')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solo se permiten correos @unimet.edu.ve'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Inicio de carga (bloqueamos el botón)
    setState(() => _isLoading = true);

    String? error;
    if (_isLogin) {
      // INTENTAR INICIAR SESIÓN
      error = await _authService.loginUser(email, password);
    } else {
      // INTENTAR REGISTRARSE
      error = await _authService.registerUser(email, password);
    }

    // Fin de carga
    setState(() => _isLoading = false);

    // Verificamos si la pantalla sigue abierta antes de usar el contexto
    if (!mounted) return;

    if (error == null) {
      // --- CASO DE ÉXITO ---
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isLogin ? '¡Bienvenido!' : '¡Cuenta creada con éxito!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // AQUÍ ESTÁ LA MAGIA: Navegamos al Home y cerramos el Login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
      
    } else {
      // --- CASO DE ERROR ---
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo e Icono
              const Icon(Icons.storefront, size: 80, color: Colors.orange),
              const SizedBox(height: 20),
              const Text(
                "MetroFeria Express",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              // Campo de Correo
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Correo Unimet",
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                  hintText: "usuario@unimet.edu.ve",
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Campo de Contraseña
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: "Contraseña",
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 30),

              // Botón Principal (Login / Registro)
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
                          style: const TextStyle(fontSize: 18, color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // Texto para cambiar entre modos
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