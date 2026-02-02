import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:metro_feria/services/auth_service.dart';
import 'package:metro_feria/models/product_model.dart'; // Importa el modelo

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Favoritos"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      // CRITERIO 4: Persistencia (Usamos Stream para escuchar cambios en tiempo real)
      body: StreamBuilder<DocumentSnapshot>(
        stream: authService.getUserStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Obtenemos la lista de IDs guardados en Firebase
          var userData = snapshot.data!.data() as Map<String, dynamic>;
          List<dynamic> favIds = userData['favorites'] ?? [];

          if (favIds.isEmpty) {
            return const Center(
              child: Text("Aún no tienes platos favoritos 💔"),
            );
          }

          // Filtramos nuestro menú dummy para mostrar solo los que están en favoritos
          // (En el futuro, aquí harías una consulta a la colección 'products' usando 'whereIn')
          final favoriteProducts = dummyMenu
              .where((p) => favIds.contains(p.id))
              .toList();

          return ListView.builder(
            itemCount: favoriteProducts.length,
            itemBuilder: (context, index) {
              final product = favoriteProducts[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.fastfood)),
                  title: Text(product.name),
                  subtitle: Text("${product.restaurant} - \$${product.price}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () {
                      // CRITERIO 3: Al desmarcar, desaparece de la lista
                      authService.toggleFavorite(product.id);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
