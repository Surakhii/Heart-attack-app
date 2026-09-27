import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const background = Color(0xFF080418);
  static const surface = Color(0xFF0E0824);
  static const card = Color(0x0DFFFFFF);        // white 5% — glass
  static const cardBorder = Color(0x1AFFFFFF);  // white 10%
  static const redbull = Color(0xFFFF0033);
  static const monster = Color(0xFF00FF41);
  static const gold = Color(0xFFFFD700);
  static const purple = Color(0xFF8B00FF);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF8888AA);
  static const textMuted = Color(0xFF44445A);
  static const divider = Color(0x1AFFFFFF);
}

// Neon glow — apply to BoxDecoration.boxShadow
List<BoxShadow> neonGlow(Color color, {double radius = 18, double intensity = 0.55}) => [
  BoxShadow(color: color.withAlpha((intensity * 255).round()), blurRadius: radius, spreadRadius: 0),
  BoxShadow(color: color.withAlpha((intensity * 0.35 * 255).round()), blurRadius: radius * 2.5, spreadRadius: 0),
];

// Glass card decoration
BoxDecoration glassCard({Color? borderColor, List<BoxShadow>? glow}) => BoxDecoration(
  color: AppColors.card,
  borderRadius: BorderRadius.circular(20),
  border: Border.all(color: borderColor ?? AppColors.cardBorder, width: 1),
  boxShadow: glow,
);

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.redbull,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.rajdhani(
        fontSize: 64, fontWeight: FontWeight.w900,
        color: AppColors.textPrimary, letterSpacing: -3, height: 0.9,
      ),
      displayMedium: GoogleFonts.rajdhani(
        fontSize: 48, fontWeight: FontWeight.w900,
        color: AppColors.textPrimary, letterSpacing: -2,
      ),
      headlineLarge: GoogleFonts.rajdhani(
        fontSize: 32, fontWeight: FontWeight.w800,
        color: AppColors.textPrimary, letterSpacing: -0.5,
      ),
      headlineMedium: GoogleFonts.rajdhani(
        fontSize: 26, fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 17, fontWeight: FontWeight.w700,
        color: AppColors.textPrimary, letterSpacing: -0.3,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
      ),
      bodyLarge: GoogleFonts.inter(fontSize: 15, color: AppColors.textPrimary),
      bodyMedium: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
      labelLarge: GoogleFonts.inter(
        fontSize: 11, fontWeight: FontWeight.w700,
        letterSpacing: 1.5, color: AppColors.textSecondary,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.card,
      selectedColor: AppColors.redbull.withAlpha(30),
      labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
      side: const BorderSide(color: AppColors.cardBorder),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xCC0E0824),
      indicatorColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return GoogleFonts.inter(
          fontSize: 11,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? AppColors.redbull : AppColors.textMuted,
        );
      }),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surface,
      contentTextStyle: GoogleFonts.inter(color: AppColors.textPrimary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

// Reusable aurora background widget — wrap any screen body with this
class AuroraBackground extends StatelessWidget {
  final Widget child;
  final Color? accent1;
  final Color? accent2;

  const AuroraBackground({
    super.key,
    required this.child,
    this.accent1,
    this.accent2,
  });

  @override
  Widget build(BuildContext context) {
    final c1 = accent1 ?? AppColors.redbull;
    final c2 = accent2 ?? AppColors.purple;
    return Stack(
      children: [
        // base
        Container(color: AppColors.background),
        // top-left blob
        Positioned(
          top: -120, left: -80,
          child: Container(
            width: 380, height: 380,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [c1.withAlpha(55), Colors.transparent]),
            ),
          ),
        ),
        // bottom-right blob
        Positioned(
          bottom: -140, right: -100,
          child: Container(
            width: 340, height: 340,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [c2.withAlpha(45), Colors.transparent]),
            ),
          ),
        ),
        // top-right small
        Positioned(
          top: 200, right: -60,
          child: Container(
            width: 200, height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [c2.withAlpha(30), Colors.transparent]),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
