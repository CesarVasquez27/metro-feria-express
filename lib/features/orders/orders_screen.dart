import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:metro_feria/services/order_service.dart';
import 'package:metro_feria/models/product_model.dart';
import 'package:metro_feria/services/cart_service.dart';
import 'package:metro_feria/features/cart/cart_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return "Fecha desconocida";
    final date = timestamp.toDate();
    return "${date.day}/${date.month} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'listo':
        return Colors.green;
      case 'entregado':
        return Colors.blue;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  // --- LÓGICA CORREGIDA ---
  void _repeatOrder(BuildContext context, List<dynamic> oldItems) {
    final cartService = CartService();
    int addedCount = 0;
    int missingCount = 0;

    for (var item in oldItems) {
      // CORRECCIÓN: Usamos 'productId' que es como lo guardamos en Firebase
      String oldId = item['productId'];
      int quantity = item['quantity'];

      // Buscamos si existe en el menú actual
      final productExists = dummyMenu.any((p) => p.id == oldId);

      if (productExists) {
        final currentProduct = dummyMenu.firstWhere((p) => p.id == oldId);

        // Agregamos al carrito la cantidad de veces necesaria
        for (int i = 0; i < quantity; i++) {
          cartService.addToCart(currentProduct);
        }
        addedCount++;
      } else {
        missingCount++;
      }
    }

    // Feedback al usuario
    if (missingCount > 0 && addedCount > 0) {
      _showDialog(
        context,
        "Atención",
        "Se agregaron los productos disponibles, pero $missingCount ya no existen en el menú.",
        true, // Ir al carrito
      );
    } else if (missingCount > 0 && addedCount == 0) {
      _showDialog(
        context,
        "Lo sentimos",
        "Los productos de este pedido ya no están disponibles en el menú actual.",
        false,
      );
    } else {
      // ÉXITO TOTAL
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("¡Pedido agregado al carrito! 🛒")),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CartScreen()),
      );
    }
  }

  void _showDialog(
    BuildContext context,
    String title,
    String content,
    bool goToCart,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (goToCart) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                );
              }
            },
            child: Text(goToCart ? "IR AL CARRITO" : "ENTENDIDO"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderService = OrderService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Pedidos"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: orderService.getMyOrders(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return Center(child: Text("Error: ${snapshot.error}"));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.receipt_long, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No tienes pedidos recientes.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final orderData = orders[index].data() as Map<String, dynamic>;

              // Datos seguros con valores por defecto
              final status = orderData['status'] ?? 'Desconocido';
              final items = orderData['items'] as List<dynamic>? ?? [];
              final total = (orderData['total'] ?? 0.0)
                  .toDouble(); // Aseguramos double
              final timestamp = orderData['timestamp'] as Timestamp?;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ENCABEZADO
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDate(timestamp),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(status).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _getStatusColor(status),
                              ),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                color: _getStatusColor(status),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(),

                      // LISTA DE PLATOS
                      ...items.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            children: [
                              Text(
                                "${item['quantity']}x ",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Expanded(child: Text("${item['name']}")),
                              Text(
                                "\$${item['price']}",
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      }),

                      const Divider(),

                      // TOTAL Y BOTÓN
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            // LLAMADA A LA FUNCIÓN CORREGIDA
                            onPressed: () => _repeatOrder(context, items),
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text("Volver a Pedir"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade50,
                              foregroundColor: Colors.orange,
                              elevation: 0,
                            ),
                          ),

                          Text(
                            "\$${total.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
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
