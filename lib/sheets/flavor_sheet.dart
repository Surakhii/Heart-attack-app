import 'package:flutter/material.dart';
import '../models/flavor.dart';
import '../data/flavors_data.dart';
import '../theme/app_theme.dart';
import '../widgets/flavor_card.dart';
import 'size_sheet.dart';

Future<void> showFlavorSheet(BuildContext context, Brand brand) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => _FlavorSheet(brand: brand),
  );
}

class _FlavorSheet extends StatelessWidget {
  final Brand brand;
  const _FlavorSheet({required this.brand});

  @override
  Widget build(BuildContext context) {
    final flavors = brand == Brand.redbull ? redbullFlavors : monsterFlavors;
    final accent = brand == Brand.redbull ? AppColors.redbull : AppColors.monster;
    final brandName = brand == Brand.redbull ? 'Red Bull' : 'Monster';

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) => Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textMuted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 24,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Pick your $brandName',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.9,
              ),
              itemCount: flavors.length,
              itemBuilder: (ctx, i) => FlavorCard(
                flavor: flavors[i],
                onTap: () async {
                  final logged = await showSizeSheet(context, flavors[i]);
                  if (logged && context.mounted) Navigator.of(context).pop();
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
