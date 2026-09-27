import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/flavor.dart';
import '../theme/app_theme.dart' show neonGlow;

class FlavorCard extends StatefulWidget {
  final Flavor flavor;
  final VoidCallback onTap;

  const FlavorCard({super.key, required this.flavor, required this.onTap});

  @override
  State<FlavorCard> createState() => _FlavorCardState();
}

class _FlavorCardState extends State<FlavorCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.flavor.color;
    final textColor = widget.flavor.textColor;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        decoration: BoxDecoration(
          color: color.withAlpha(_pressed ? 60 : 35),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withAlpha(_pressed ? 200 : 90),
            width: 1.5,
          ),
          boxShadow: _pressed
              ? neonGlow(color, radius: 20, intensity: 0.5)
              : neonGlow(color, radius: 8, intensity: 0.15),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // caffeine pill top-right
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withAlpha(50),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${widget.flavor.sizes.first.caffeineMg}mg',
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const Spacer(),
            // colored dot accent
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: neonGlow(color, radius: 6, intensity: 0.8),
              ),
            ),
            Text(
              widget.flavor.name,
              style: GoogleFonts.rajdhani(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
