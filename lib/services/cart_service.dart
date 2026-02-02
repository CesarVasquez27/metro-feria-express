import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:metro_feria/models/product_model.dart';

// Modelo simple para un ítem dentro del carrito
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get totalPrice => product.price * quantity;
}

class CartService {
  // Patrón Singleton: Para que el carrito sea el mismo en toda la app
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  // Lista de productos en el carrito
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  // Calcular total a pagar
  double get totalAmount {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  // Agregar producto
  void addToCart(Product product) {
    // Si ya existe, sumamos cantidad
    for (var item in _items) {
      if (item.product.id == product.id) {
        item.quantity++;
        return;
      }
    }
    // Si no existe, lo agregamos nuevo
    _items.add(CartItem(product: product));
  }

  // Quitar producto (uno por uno)
  void removeSingleItem(String productId) {
    for (var item in _items) {
      if (item.product.id == productId) {
        if (item.quantity > 1) {
          item.quantity--;
        } else {
          _items.remove(item);
        }
        return;
      }
    }
  }

  // Vaciar carrito
  void clear() {
    _items.clear();
  }

  // --- ENVIAR PEDIDO A FIREBASE (CRUCIAL PARA EL HISTORIAL) ---
  Future<void> placeOrder() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (_items.isEmpty) throw Exception("El carrito está vacío");

    final orderRef = FirebaseFirestore.instance.collection('orders');

    await orderRef.add({
      'userId': user.uid,
      'userEmail': user.email, // Para que el restaurante sepa quién pidió
      'total': totalAmount,
      'status': 'Preparando', // Estado inicial
      'timestamp': FieldValue.serverTimestamp(), // Hora exacta del servidor
      'items': _items
          .map(
            (item) => {
              'productId': item.product.id,
              'name': item.product.name,
              'restaurant': item.product.restaurant,
              'quantity': item.quantity,
              'price': item.product.price,
            },
          )
          .toList(),
    });

    clear(); // Vaciamos el carrito después de pedir
  }
}
