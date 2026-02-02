import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtener el flujo (Stream) de pedidos del usuario actual
  Stream<QuerySnapshot> getMyOrders() {
    final user = _auth.currentUser;
    if (user == null) {
      // Si no hay usuario, retornamos un stream vacío
      return const Stream.empty();
    }

    return _db
        .collection('orders')
        .where('userId', isEqualTo: user.uid) // Solo MIS pedidos
        .orderBy('timestamp', descending: true) // Los más nuevos primero
        .snapshots();
  }
}
