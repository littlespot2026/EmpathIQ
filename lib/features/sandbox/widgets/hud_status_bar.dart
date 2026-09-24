import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class HudStatusBar extends StatelessWidget {
  final String characterName;
  final String relationship;
  final int defensePercent;
  final String currentInnerThought;

  const HudStatusBar({
    super.key,
    required this.characterName,
    required this.relationship,
    required this.defensePercent,
    required this.currentInnerThought,
  });

  Color get _gaugeColor {
    if (defensePercent <= 35) return AppColors.empathyGreen;
    if (defensePercent <= 70) return AppColors.agitatedYellow;
    return AppColors.flammableRed;
  }

  String get _statusLabel {
    if (defensePercent <= 35) return '心防解除 · 处于沟通安全区';
    if (defensePercent <= 70) return '心存戒备 · 试探观望中';
    return '防御紧绷 · 易燃对抗态';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          bottom: BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: NPC Identity & Defense Percent
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      shape: BoxShape.circle,
                      border: Border.all(color: _gaugeColor, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        characterName.isNotEmpty ? characterName[0] : '对',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _gaugeColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            characterName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.borderLight, width: 0.5),
                            ),
                            child: Text(
                              relationship,
                              style: const TextStyle(
                                fontSize: 9.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _statusLabel,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: _gaugeColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Gauge percentage badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _gaugeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _gaugeColor.withValues(alpha: 0.4), width: 0.8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_rounded, size: 13, color: AppColors.warmBeige),
                    const SizedBox(width: 4),
                    Text(
                      '心防: $defensePercent%',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: _gaugeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Animated Defense Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: (defensePercent / 100.0).clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 400),
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 5,
                  backgroundColor: AppColors.surfaceElevated,
                  valueColor: AlwaysStoppedAnimation<Color>(_gaugeColor),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Real-time Subtext Activity HUD
          if (currentInnerThought.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderSubtle, width: 0.6),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.psychology_outlined,
                    size: 14,
                    color: AppColors.amberSand,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '此刻内心活动：',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.amberSand,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '“$currentInnerThought”',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
