import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_vitatraz_app/theme/theme.dart';

class KeyValueRow extends StatelessWidget {
  final String label, value;
  const KeyValueRow(this.label, this.value, {super.key});

  @override
  Widget build(BuildContext c) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(flex: 3, child: Text(label, style: GoogleFonts.manrope(
          fontSize: 14, color: AppColors.secondaryText
        ))),
        Expanded(flex: 5, child: Text(value, style: GoogleFonts.manrope(
          fontSize: 14, color: AppColors.primaryText
        ))),
      ],
    ),
  );
}
