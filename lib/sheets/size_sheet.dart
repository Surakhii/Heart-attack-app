import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:vibration/vibration.dart';
import 'package:uuid/uuid.dart';
import '../data/mock_data.dart';
import '../models/flavor.dart';
import '../models/log_entry.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

Future<void> _playCanSound() async {
  try {
    final player = AudioPlayer();
    await player.play(AssetSource('sounds/can_open.mp3'));
  } catch (_) {}
}

Future<bool> showSizeSheet(BuildContext context, Flavor flavor) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => _SizeSheet(flavor: flavor),
  );
  return result == true;
}

class _SizeSheet extends ConsumerStatefulWidget {
  final Flavor flavor;
  const _SizeSheet({required this.flavor});

  @override
  ConsumerState<_SizeSheet> createState() => _SizeSheetState();
}

class _SizeSheetState extends ConsumerState<_SizeSheet> {
  late DrinkSize _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.flavor.sizes.first;
  }

  Future<void> _log() async {
    final uid = ref.read(activeUidProvider);
    if (uid.isEmpty) return;
    final entry = LogEntry(
      id: const Uuid().v4(),
      uid: uid,
      flavorId: widget.flavor.id,
      flavorName: '${widget.flavor.brandName} ${widget.flavor.name}',
      brandId: widget.flavor.brand.name,
      sizeML: _selected.ml,
      caffeineMg: _selected.caffeineMg,
      timestamp: DateTime.now(),
    );

    // Return true so flavor sheet knows to close itself
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop(true);

    unawaited(_playCanSound());
    unawaited(_pulseHaptic());

    if (ref.read(previewModeProvider)) {
      mockLogs.insert(0, entry);
    } else {
      unawaited(addLog(entry));
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text('${entry.flavorName} ${_selected.ml}ml — ${_selected.caffeineMg}mg'),
        backgroundColor: AppColors.card,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _pulseHaptic() async {
    final hasVibrator = await Vibration.hasVibrator() ?? false;
    if (!hasVibrator) return;
    // crack → hiss pattern
    Vibration.vibrate(pattern: [0, 80, 60, 180], intensities: [0, 255, 0, 180]);
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.flavor.brand == Brand.redbull
        ? AppColors.redbull
        : AppColors.monster;

    final bottomPad = MediaQuery.of(context).padding.bottom + 24;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPad),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textMuted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: widget.flavor.color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Text(
                '${widget.flavor.brandName} ${widget.flavor.name}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: widget.flavor.sizes.map((size) {
              final isSelected = size.ml == _selected.ml;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => setState(() => _selected = size),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? accent.withAlpha(30) : AppColors.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? accent : AppColors.cardBorder,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            size.label,
                            style: TextStyle(
                              color: isSelected ? accent : AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${size.caffeineMg}mg',
                            style: TextStyle(
                              color: isSelected ? accent.withAlpha(200) : AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _log,
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                'Log ${_selected.caffeineMg}mg',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
