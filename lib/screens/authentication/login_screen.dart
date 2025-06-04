import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:fl_vitatraz_app/theme/theme.dart';
import 'package:fl_vitatraz_app/screens/screens.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  // it cleans the label contains memory
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // LogIn Function
  Future<void> _logIn() async {
    setState(() => _isLoading = true);
    try {
      // checking email and password on firebase
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // if it's correct, it sends you to HomeScreen 
      Navigator.pushReplacementNamed(context, HomeScreen.routeName);
    } on FirebaseAuthException catch (e) {
      // if something is wrong, shows an SnackBar Error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Error desconocido')),
      );
    } finally {
      // after all, it change the loading value to false
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.primaryBackground,
          body: SafeArea(
            top: true,
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              child: Column(
                children: [
                  // --------------------------------
                  // ICON SECTION
                  SizedBox(
                    width: double.infinity,
                    height: size.height * 0.35,
                    child: Center(
                      child: Icon(
                        Icons.person_outline,
                        color: AppColors.secondaryText,
                        size: size.height * 0.18,
                      ),
                    ),
                  ),

                  // --------------------------------
                  // EMAIL LABEL SECTION
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Correo electrónico',
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // --------------------------------
                  // EMAIL FIELD SECTION

                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textAlign: TextAlign.center,
                    cursorColor: AppColors.primaryText,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.accent2,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --------------------------------
                  // PASSWORD LABEL SECTION
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Contraseña',
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // --------------------------------
                  // PASSWORD FIELD SECTION
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textAlign: TextAlign.center,
                    cursorColor: AppColors.primaryText,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.accent2,
                      // Adjusted contentPadding to only vertical so centering works well
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      // prefixIcon vacío para compensar espacio del suffixIcon
                      prefixIcon: const SizedBox(width: 48),
                      // allow showing password
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.primaryText,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // --------------------------------
                  // FORGOT PASSWORD SECTION
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, ForgotPasswordScreen.routeName);
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 30),
                      ),
                      child: Text(
                        '¿Constraseña olvidada?',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          decoration: TextDecoration.underline,
                          color: AppColors.primaryText,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --------------------------------
                  // LOGIN BUTTON SECTION
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: _logIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Iniciar Sesión',
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.secondaryBackground,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),

        // Loader overlay
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
