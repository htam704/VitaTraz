import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_vitatraz_app/theme/app_colors.dart';

class PatientCard extends StatelessWidget {
  final String name;
  final String dni;
  final String birthdate;
  final List<String> allergies;
  final String? avatarUrl;
  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback? onTap;

  const PatientCard({
    super.key,
    required this.name,
    required this.dni,
    required this.birthdate,
    required this.allergies,
    required this.backgroundColor,
    required this.borderColor,
    this.avatarUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor, // Border color based on gender
              width: 2, // Slightly noticeable border width
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.accent4,
                    backgroundImage:
                        avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                    child: avatarUrl == null
                        ? Icon(Icons.person,
                            size: 32, color: AppColors.secondaryText)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.manrope(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'DNI: $dni',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            color: AppColors.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Fecha de nacimiento: $birthdate',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              Divider(color: borderColor, thickness: 2, height: 0),
              const SizedBox(height: 12),

              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Alergias: ',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                      ),
                    ),
                    TextSpan(
                      text: allergies.join(', '),
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
