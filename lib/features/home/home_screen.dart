import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Imports absolutos (sin puntos)
import 'package:metro_feria/features/auth/login_screen.dart';
import 'package:metro_feria/features/profile/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Función para cerrar sesión
  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    
    // Verificamos si el widget sigue montado antes de navegar
    if (context.mounted) {
      // Volver al Login y borrar el historial para que no puedan volver atrás
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos el usuario actual para mostrar su correo
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("MetroFeria Express 🍕"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          // BOTÓN 1: Ir al Perfil (Historia de Usuario 1.3)
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Mi Perfil',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          
          // BOTÓN 2: Cerrar Sesión
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () => _logout(context),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.storefront, size: 100, color: Colors.orangeAccent),
            const SizedBox(height: 20),
            Text(
              "¡Hola, ${user?.email}!", 
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Bienvenido al mercado digital de la Unimet.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            const Text(
              "(Aquí pronto verás los restaurantes 🍔)",
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}