import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_vitatraz_app/theme/app_colors.dart';
import 'package:fl_vitatraz_app/components/components.dart';

class NotificationsScreen extends StatelessWidget {
  static const String routeName = '/notifications';

  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --------------------------------
    // Example notifications list with title, subtitle, and timestamp
    final exampleNotifications = [
      {
        'title': 'Visita programada',
        'subtitle': 'Recordatorio: Visitar a paciente en planta 3',
        'timestamp': 'Hoy, 09:00'
      },
      {
        'title': 'Medicamento administrado',
        'subtitle': 'Se administró Aspirina 100mg a María López',
        'timestamp': 'Ayer, 17:45'
      },
      {
        'title': 'Nuevo paciente asignado',
        'subtitle': 'Has sido asignado al paciente Juan García',
        'timestamp': 'Hace 2 días'
      },
      {
        'title': 'Tarea completada',
        'subtitle': 'Tarea “Revisar signos vitales” completada',
        'timestamp': 'Hace 3 días'
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      // --------------------------------
      // AppBar with back button and title
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: const BackButton(color: AppColors.secondaryBackground),
        title: Text(
          'Notificaciones',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.secondaryBackground,
          ),
        ),
      ),
      // --------------------------------
      // Bottom navigation bar highlighting this tab
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 1),

      body: SafeArea(
        bottom: false, // avoid overlap with system UI at bottom
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --------------------------------
              // Display number of notifications
              Text(
                'Tienes ${exampleNotifications.length} notificaciones',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 16),
              // --------------------------------
              // Show list of notifications or empty state if none
              Expanded(
                child: exampleNotifications.isNotEmpty
                    ? ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: exampleNotifications.length,
                        itemBuilder: (context, index) {
                          final notif = exampleNotifications[index];
                          return NotificationCard(
                            title: notif['title']!,      // notification title
                            subtitle: notif['subtitle']!, // notification subtitle
                            timestamp: notif['timestamp']!, // when it occurred
                          );
                        },
                      )
                    : Center(
                        child: Text(
                          'No hay notificaciones pendientes.',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            color: AppColors.secondaryText,
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
