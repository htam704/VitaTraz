import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_vitatraz_app/theme/theme.dart'; // Importa tu tema y colores

class ForgotPasswordScreen extends StatefulWidget {
  static const String routeName = '/forgotPassword';
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  // Reset Password Function
  Future<void> _sendPasswordResetEmail() async {
    final email = _emailController.text.trim();

    // if no email is entered, show a SnackBar asking to enter it
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor, introduce tu correo',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // if there is an email, start loading
    setState(() => _isLoading = true);

    // send recovery email
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Correo de recuperación enviado',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context); // return to LoginScreen
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? 'Error al enviar el correo',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      // stop loading
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Screen size if needed later
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white, // Set a white background like in your design
          // --------------------------------
          // APPBAR
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            elevation: 0, // Remove shadow to match design
            leading: const BackButton(
              color: Colors.white, // Ensure back arrow is white
            ),
            title: Text(
              'Recuperar contraseña',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white, // Title in white
                  ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --------------------------------
                // LABEL SECTION
                Text(
                  'Introduce tu correo para recibir un enlace de recuperación:',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    color: AppColors.primaryText, // Asegúrate de que sea un gris oscuro
                  ),
                ),
                const SizedBox(height: 20),
                // --------------------------------
                // EMAIL SECTION
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center, // Center the text inside the field
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    color: AppColors.primaryText,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Correo electrónico', // Use hintText instead of labelText
                    hintStyle: GoogleFonts.manrope(
                      fontSize: 16,
                      color: AppColors.secondaryText,
                    ),
                    filled: true,
                    fillColor: AppColors.accent4, // Light gray background for the field
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // --------------------------------
                // BUTTON SECTION
                SizedBox(
                  width: double.infinity,
                  height: 48, // Slightly taller button for better tap area
                  child: ElevatedButton(
                    onPressed: _sendPasswordResetEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary, // Blue button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Enviar correo',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.secondaryBackground, // White text
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        if (_isLoading)
          const Opacity(
            opacity: 0.6,
            child: ModalBarrier(dismissible: false, color: Colors.black),
          ),
        if (_isLoading) const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
