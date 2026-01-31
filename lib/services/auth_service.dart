import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Registro con correo y contraseña
  Future<String?> registerUser(String email, String password) async {
    try {
      // 1. Crear usuario en Authentication
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = result.user;

      // 2. Crear documento en Firestore (Base de datos)
      await _db.collection('users').doc(user!.uid).set({
        'email': email,
        'role': 'student', // Por defecto todos son estudiantes
        'favorites': [],   // Lista vacía de favoritos
        'createdAt': DateTime.now(),
      });

      return null; // Null significa que no hubo error
    } on FirebaseAuthException catch (e) {
      return e.message; // Devolvemos el mensaje de error si falla
    }
  }

  // Login normal
  Future<String?> loginUser(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Éxito
    } on FirebaseAuthException catch (e) {
      return e.message; // Error
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // 1. Obtener datos del usuario en tiempo real
  Stream<DocumentSnapshot> getUserStream() {
    final user = _auth.currentUser;
    return _db.collection('users').doc(user!.uid).snapshots();
  }

  // 2. Actualizar Perfil (Historia de Usuario: Carnet y Teléfono)
  Future<String?> updateProfile({
    required String carnet,
    required String phone,
  }) async {
    try {
      final user = _auth.currentUser;
      await _db.collection('users').doc(user!.uid).update({
        'carnet': carnet,
        'phone': phone,
      });
      return null; // Éxito
    } catch (e) {
      return "Error al actualizar: $e";
    }
  }
}