import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_vitatraz_app/theme/app_colors.dart';

class PatientRecord extends StatelessWidget {
  final String name;
  final String dni;
  final String createdDate;
  final String diagnosis;
  final String reason;
  final String age;
  final String sex;
  final String? avatarUrl;
  final VoidCallback? onTap;

  const PatientRecord({
    super.key,
    required this.name,
    required this.dni,
    required this.createdDate,
    required this.diagnosis,
    required this.reason,
    required this.age,
    required this.sex,
    this.avatarUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.secondaryBackground,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.secondaryBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.accent3,
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
                          'Fecha de creación: $createdDate',
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
              Divider(
                color: AppColors.accent1,
                thickness: 2,
                height: 0,
              ),
              const SizedBox(height: 12),

              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Diagnóstico principal: ',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                      ),
                    ),
                    TextSpan(
                      text: diagnosis,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Motivo de ingreso: ',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                      ),
                    ),
                    TextSpan(
                      text: reason,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Edad: ',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                      ),
                    ),
                    TextSpan(
                      text: age,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const TextSpan(text: '    '),
                    TextSpan(
                      text: 'Sexo: ',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                      ),
                    ),
                    TextSpan(
                      text: sex,
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
