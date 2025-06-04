import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_vitatraz_app/theme/app_colors.dart';
import 'package:fl_vitatraz_app/components/components.dart';

class PrivacyScreen extends StatefulWidget {
  static const String routeName = '/privacy';

  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  // Whether user allows sharing data with third parties
  bool _shareDataWithThirdParties = false;
  // Whether user’s profile is visible to patients
  bool _showProfileToPatients = true;
  // Whether user wants to receive marketing emails
  bool _receiveMarketingEmails = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      // --------------------------------
      // AppBar with back button and title
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: const BackButton(color: AppColors.secondaryBackground),
        title: Text(
          'Privacidad',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.secondaryBackground,
          ),
        ),
      ),
      // --------------------------------
      // Bottom navigation bar, highlighting this tab (index 1)
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 1),

      body: SafeArea(
        bottom: false, // avoid overlapping with system UI at bottom
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --------------------------------
                // Header text for privacy settings
                Text(
                  'Configuración de Privacidad',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 16),
                // Description of privacy screen purpose
                Text(
                  'Controla cómo se comparte tu información y qué notificaciones recibes.',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 24),
                // --------------------------------
                // Toggle: share data with third parties
                SwitchListTile(
                  title: Text(
                    'Compartir datos con terceros',
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      color: AppColors.primaryText,
                    ),
                  ),
                  subtitle: Text(
                    'Permitir que tus datos sean compartidos con socios autorizados.',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  value: _shareDataWithThirdParties,
                  onChanged: (val) {
                    setState(() => _shareDataWithThirdParties = val);
                  },
                  activeColor: AppColors.primary,
                ),
                const Divider(height: 32),
                // --------------------------------
                // Toggle: show profile to patients
                SwitchListTile(
                  title: Text(
                    'Mostrar perfil a pacientes',
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      color: AppColors.primaryText,
                    ),
                  ),
                  subtitle: Text(
                    'Permitir que los pacientes vean tu perfil básico.',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  value: _showProfileToPatients,
                  onChanged: (val) {
                    setState(() => _showProfileToPatients = val);
                  },
                  activeColor: AppColors.primary,
                ),
                const Divider(height: 32),
                // --------------------------------
                // Toggle: receive marketing emails
                SwitchListTile(
                  title: Text(
                    'Recibir correos de marketing',
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      color: AppColors.primaryText,
                    ),
                  ),
                  subtitle: Text(
                    'Recibe noticias y ofertas vía email.',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  value: _receiveMarketingEmails,
                  onChanged: (val) {
                    setState(() => _receiveMarketingEmails = val);
                  },
                  activeColor: AppColors.primary,
                ),
                const Divider(height: 32),
                // --------------------------------
                // Button to save preferences
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      // Show confirmation message when preferences are saved
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Preferencias guardadas')),
                      );
                    },
                    child: Text(
                      'Guardar preferencias',
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryBackground,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
