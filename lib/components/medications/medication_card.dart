import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_vitatraz_app/theme/theme.dart';
import 'package:fl_vitatraz_app/models/medicamento.dart';

class MedicationCard extends StatelessWidget {
  final Medicamento medicamento;
  final VoidCallback? onTap;

  const MedicationCard({
    super.key,
    required this.medicamento,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const double imageSize = 60;
    final String? urlFoto = medicamento.fotos.isNotEmpty ? medicamento.fotos.first : null;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: AppColors.secondaryBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: imageSize,
                height: imageSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                clipBehavior: Clip.hardEdge,
                child: urlFoto != null
                    ? Image.network(
                        urlFoto,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) {
                          return const Icon(
                            Icons.medication_outlined,
                            size: 32,
                            color: Colors.grey,
                          );
                        },
                      )
                    : const Icon(
                        Icons.medication_outlined,
                        size: 32,
                        color: Colors.grey,
                      ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicamento.nombre,
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      medicamento.labtitular,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
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
