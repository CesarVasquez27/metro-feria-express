import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:metro_feria/services/auth_service.dart'; // Asegúrate de que el import sea correcto

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _carnetController = TextEditingController();
  final _phoneController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  // Actualizar datos en Firebase
  void _saveProfile() async {
    // Primero validamos el formulario (Regex de teléfono, campos vacíos, etc.)
    if (_formKey.currentState!.validate()) {
      // Iniciamos carga
      setState(() => _isLoading = true);

      // CRITERIO 4: Guardar exitosamente en base de datos
      // La variable 'error' será null si todo salió bien, o tendrá texto si falló.
      String? error = await _authService.updateProfile(
        carnet: _carnetController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      // Terminamos carga
      setState(() => _isLoading = false);

      // Verificamos si la pantalla sigue viva
      if (!mounted) return;

      // --- CORRECCIÓN ---
      if (error != null) {
        // CASO 1: HUBO ERROR (Texto Rojo)
        // Al entrar al if, Dart ya sabe que 'error' es un String seguro.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      } else {
        // CASO 2: ÉXITO (Texto Verde)
        // Si error es null, mostramos confirmación de éxito.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Datos actualizados correctamente!'),
            backgroundColor: Colors.green,
          ),
        );

        // Opcional: Podrías regresar a la pantalla anterior si quisieras
        // Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi Perfil"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _authService.getUserStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Recuperamos los datos actuales para mostrarlos en los campos
          var data = snapshot.data!.data() as Map<String, dynamic>?;
          // Este truco evita que se borre lo que escribes si la base de datos se actualiza sola
          if (_carnetController.text.isEmpty) {
            _carnetController.text = data?['carnet'] ?? '';
          }
          if (_phoneController.text.isEmpty) {
            _phoneController.text = data?['phone'] ?? '';
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Datos Académicos y de Contacto",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // --- CAMPO CARNET ---
                  TextFormField(
                    controller: _carnetController,
                    decoration: const InputDecoration(
                      labelText: "Carnet *",
                      hintText: "Ej. 20211110055",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.badge),
                    ),
                    keyboardType: TextInputType.number,
                    // CRITERIO 2: Carnet obligatorio
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El carnet es obligatorio para pedir';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // --- CAMPO TELÉFONO ---
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: "Teléfono (WhatsApp) *",
                      hintText: "Ej. 04141234567",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone_android),
                    ),
                    keyboardType: TextInputType.phone,
                    // CRITERIO 1: Formato venezolano (04xx...)
                    // CRITERIO 3: Editable en cualquier momento (TextFormField lo permite por defecto)
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El teléfono es obligatorio';
                      }
                      // Explicación Regex: Empieza por 0, sigue con 4, y luego 9 dígitos más.
                      final phoneRegex = RegExp(r'^04\d{9}$');
                      if (!phoneRegex.hasMatch(value)) {
                        return 'Formato inválido. Usa: 04141234567';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "GUARDAR CAMBIOS",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
