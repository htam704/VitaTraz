import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_vitatraz_app/theme/theme.dart';

class Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? action;
  final List<Widget> children;

  const Section({
    super.key,
    required this.title,
    required this.icon,
    this.action,
    required this.children,
  });

  @override
  Widget build(BuildContext c) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.secondaryBackground,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(
        color: Colors.black.withOpacity(0.03),
        blurRadius: 6,
        offset: const Offset(0,3),
      )],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(child: Text(title, style: GoogleFonts.manrope(
              fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primaryText
            ))),
            if (action != null) action!,
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    ),
  );
}
