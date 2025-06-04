import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:fl_vitatraz_app/theme/theme.dart';

class AddTodoScreen extends StatefulWidget {
  static const String routeName = '/add-todo';

  const AddTodoScreen({super.key});

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  // --------------------------------
  // Form key to validate inputs
  final _formKey = GlobalKey<FormState>();
  // Controller for the task description input
  final _mensajeController = TextEditingController();
  // Importance level (1 = low, 2 = medium, 3 = high)
  int _nivelImportancia = 1;

  // --------------------------------
  // Save the new to-do item to Firestore
  void _guardarTodo() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      final email = user?.email;

      if (email == null) {
        // If no user is logged in, show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: No user logged in')),
        );
        return;
      }

      // Add a new document under the logged-in nurse's TO-DO collection
      await FirebaseFirestore.instance
          .collection('enfermeros')
          .doc(email)
          .collection('TO-DO')
          .add({
        'mensaje': _mensajeController.text,       // Task description
        'nivelImportancia': _nivelImportancia,     // Importance level
        'completada': false,                       // Initially not completed
        'fechaCreacion': FieldValue.serverTimestamp(), // Creation timestamp
      });

      // Return to previous screen after saving
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    // Dispose controller to free resources
    _mensajeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      // --------------------------------
      // AppBar with title and back button
      appBar: AppBar(
        title: const Text('Añadir tarea'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey, // Assign form key to validate inputs
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --------------------------------
                // Label for task description
                Text(
                  'Descripción',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 10),
                // TextFormField for entering task description
                TextFormField(
                  controller: _mensajeController,
                  minLines: 3,
                  maxLines: 15,
                  decoration: InputDecoration(
                    hintText: 'Describe la tarea con detalle...',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Campo obligatorio' // Validation: required field
                      : null,
                ),
                const SizedBox(height: 24),
                // --------------------------------
                // Label for importance level
                Text(
                  'Nivel de importancia',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                // Row of buttons to select importance level
                Row(
                  children: [
                    _buildNivelButton(1, Colors.green, 'Baja'),  // Low importance
                    _buildNivelButton(2, Colors.amber, 'Media'),  // Medium importance
                    _buildNivelButton(3, Colors.red, 'Alta'),     // High importance
                  ],
                ),
                const SizedBox(height: 40),
                // --------------------------------
                // Button to add the new task
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _guardarTodo, // Call save function
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Añadir tarea'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --------------------------------
  // Widget to build each importance level button
  Widget _buildNivelButton(int nivel, Color color, String label) {
    final isSelected = _nivelImportancia == nivel; // Check if this level is selected
    return Expanded(
      child: GestureDetector(
        onTap: () {
          // Update selected importance level on tap
          setState(() {
            _nivelImportancia = nivel;
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white, // Highlight if selected
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 2),
          ),
          child: Column(
            children: [
              Icon(Icons.flag, color: isSelected ? Colors.white : color),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}