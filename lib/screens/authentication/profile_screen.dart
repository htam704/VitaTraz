import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:fl_vitatraz_app/theme/app_colors.dart';
import 'package:fl_vitatraz_app/components/components.dart';
import 'package:fl_vitatraz_app/screens/settings/edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  static const String routeName = '/profile';
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _currentUser;
  // firebase doc structure:
  DocumentReference<Map<String, dynamic>>? _nurseDocRef;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null && _currentUser!.email != null) {
      _nurseDocRef = FirebaseFirestore.instance
          .collection('enfermeros')
          .doc(_currentUser!.email!); // loged nurse id reference
    } else {
      _nurseDocRef = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // if there's no nurses logued...
    if (_currentUser == null || _nurseDocRef == null) {
      return Scaffold(
        backgroundColor: AppColors.primaryBackground,
        body: Center(
          child: Text(
            'Usuario no autenticado o perfil no disponible.',
            style: GoogleFonts.manrope(
              fontSize: 16,
              color: AppColors.primaryText,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 1),
      body: SafeArea(
        bottom: false,
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          // snapshots from firebase based on changes
          stream: _nurseDocRef!.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) { // firebase state
              // while waiting... 
              return const Center(child: CircularProgressIndicator());
            }
            // in case that there's no data on the doc
            if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
              return Center(
                child: Text(
                  'Error al cargar datos del perfil.',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    color: AppColors.primaryText,
                  ),
                ),
              );
            }

            // firebase database variables
            final data = snapshot.data!.data()!;
            final nombre = data['nombre'] as String? ?? '';
            final email = _currentUser!.email!;
            final numeroTelefono = data['numeroTelefono']?.toString() ?? '';
            final avatarUrl = data['avatarUrl'] as String?;

            // --------------------------------
            // PROFILE CARD SECTION
            return Column(
              children: [
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          offset: const Offset(0, 4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 24),
                    child: Column(
                      children: [
                        // --------------------------------
                        // AVATAR
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: AppColors.secondaryBackground,
                          backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                              ? NetworkImage(avatarUrl)
                              : null,
                          child: (avatarUrl == null || avatarUrl.isEmpty)
                              ? Text(
                                  nombre.isNotEmpty ? nombre[0] : '',
                                  style: GoogleFonts.manrope(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        // --------------------------------
                        // NAME
                        const SizedBox(height: 24),
                        Text(
                          nombre,
                          style: GoogleFonts.manrope(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondaryBackground,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        // --------------------------------
                        // EMAIL
                        const SizedBox(height: 8),
                        Text(
                          email,
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color:
                                AppColors.secondaryBackground.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // --------------------------------
                        // PHONE NUMBER
                        Text(
                          numeroTelefono,
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color:
                                AppColors.secondaryBackground.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // --------------------------------
                        // EDIT PROFILE BUTTON
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondaryBackground,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, EditProfileScreen.routeName);
                            },
                            child: Text(
                              'Editar Perfil',
                              style: GoogleFonts.manrope(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // --------------------------------
                // SETTINGS SECTION
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 1,
                    child: Column(
                      children: const [
                        _ProfileOptionTile(
                          icon: Icons.notifications_outlined,
                          title: 'Notificaciones',
                          onTapRoute: '/notifications',
                        ),
                        Divider(height: 1),
                        _ProfileOptionTile(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacidad',
                          onTapRoute: '/privacy',
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                // --------------------------------
                // LOG OUT BUTTON SECTION
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        FirebaseAuth.instance.signOut();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: Text(
                        'Cerrar Sesión',
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondaryBackground,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProfileOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String onTapRoute;

  const _ProfileOptionTile({
    required this.icon,
    required this.title,
    required this.onTapRoute,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: GoogleFonts.manrope(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.primaryText,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.pushNamed(context, onTapRoute);
      },
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
