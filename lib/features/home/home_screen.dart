import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- IMPORTS DE PANTALLAS ---
import 'package:metro_feria/features/auth/login_screen.dart';
import 'package:metro_feria/features/profile/profile_screen.dart';
import 'package:metro_feria/features/favorites/favorites_screen.dart';
import 'package:metro_feria/features/cart/cart_screen.dart';
import 'package:metro_feria/features/orders/orders_screen.dart'; // <--- NUEVO: Historial

// --- IMPORTS DE LÓGICA ---
import 'package:metro_feria/models/product_model.dart';
import 'package:metro_feria/services/auth_service.dart';
import 'package:metro_feria/services/cart_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Función para cerrar sesión de forma segura
  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final authService = AuthService();
    final cartService = CartService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("MetroFeria Express 🍕"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          // 1. BOTÓN CARRITO (Ver cesta actual)
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            tooltip: 'Ver Carrito',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),

          // 2. BOTÓN PEDIDOS (Ver historial/recibos) - NUEVO
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: 'Mis Pedidos',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OrdersScreen()),
              );
            },
          ),

          // 3. BOTÓN FAVORITOS (Ver guardados)
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Mis Favoritos',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoritesScreen(),
                ),
              );
            },
          ),

          // 4. BOTÓN PERFIL (Datos usuario)
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

          // 5. BOTÓN SALIR
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () => _logout(context),
          ),
        ],
      ),

      // STREAMBUILDER: Escucha cambios en los favoritos en tiempo real
      body: StreamBuilder<DocumentSnapshot>(
        stream: authService.getUserStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Recuperamos la lista de favoritos desde Firebase
          List<dynamic> myFavorites = [];
          if (snapshot.hasData && snapshot.data!.data() != null) {
            var userData = snapshot.data!.data() as Map<String, dynamic>;
            myFavorites = userData['favorites'] ?? [];
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER CON SALUDO
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hola, ${user?.email?.split('@')[0]} 👋",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "¿Qué te provoca comer hoy?",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              // LISTA DE PLATOS (DUMMY DATA)
              Expanded(
                child: ListView.builder(
                  itemCount: dummyMenu.length,
                  itemBuilder: (context, index) {
                    final product = dummyMenu[index];
                    final isFav = myFavorites.contains(product.id);

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10),
                        // IMAGEN DEL PLATO (Icono por ahora)
                        leading: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.fastfood,
                            color: Colors.orange,
                            size: 30,
                          ),
                        ),

                        // DATOS DEL PLATO
                        title: Text(
                          product.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(product.restaurant),

                        // PRECIO Y ACCIONES
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "\$${product.price}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 8),

                            // ACCIÓN 1: FAVORITO
                            IconButton(
                              icon: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                color: isFav ? Colors.red : Colors.grey,
                              ),
                              onPressed: () {
                                authService.toggleFavorite(product.id);
                              },
                            ),

                            // ACCIÓN 2: AGREGAR AL CARRITO
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                                constraints:
                                    const BoxConstraints(), // Hace el botón más compacto
                                onPressed: () {
                                  cartService.addToCart(product);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "${product.name} agregado al carrito 🛒",
                                      ),
                                      duration: const Duration(seconds: 1),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
