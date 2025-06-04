import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:fl_vitatraz_app/theme/theme.dart';
import 'package:fl_vitatraz_app/screens/screens.dart';

class WelcomeScreen extends StatelessWidget {
  static const String routeName = '/welcome';

  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // It save the screen size
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        top: true, // notch overlap
        bottom: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // --------------------------------
              // LOGO
              Image.asset(
                'assets/logo.png', // pubspec.yaml
                width: size.width * 0.6,
                fit: BoxFit.contain,
              ),
              // --------------------------------
              // BUTTON SECTION
              SizedBox(
                width: size.width * 0.4,
                height: 40,
                child: OutlinedButton(
                  onPressed: () async { // auth control async function
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      try {
                        // force reload from server
                        // if the user have changed, it returns an error
                        await user.reload();
                        // if the user is still on firebase, it send you to HomeScreen
                        if (!context.mounted) return; // controlling old version context problems
                        Navigator.pushReplacementNamed(context, HomeScreen.routeName);
                        return;
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'user-not-found') {
                          // if the problem is for not existing user: 
                          // it sign out and send you to LogIn Screen                          
                          await FirebaseAuth.instance.signOut();
                          Navigator.pushReplacementNamed(context, LoginScreen.routeName);
                          return;
                        }
                      }
                    }
                    // if the user is null it send you to LogIn Screen without checking
                    Navigator.pushReplacementNamed(context, LoginScreen.routeName);
                  },
                  // button styles:
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.secondaryBackground),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  // button text
                  child: Text(
                    'Comenzar',
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondaryBackground,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}