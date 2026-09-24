import 'package:flutter/material.dart';
import '../../../core/localization/app_locale.dart';
import '../../../core/theme/app_colors.dart';

class SettlementDialog extends StatelessWidget {
  final int finalDefense;
  final int totalTurns;
  final VoidCallback onRetry;
  final VoidCallback onFinish;

  const SettlementDialog({
    super.key,
    required this.finalDefense,
    required this.totalTurns,
    required this.onRetry,
    required this.onFinish,
  });

  int get _score {
    // Lower final defense means higher score
    final s = 100 - (finalDefense * 0.7).round();
    return s.clamp(40, 99);
  }

  String get _rankTitle {
    if (_score >= 90) return tr('rank_lv5');
    if (_score >= 80) return tr('rank_lv4');
    if (_score >= 70) return tr('rank_lv3');
    return tr('rank_lv2');
  }

  String get _mentorComment {
    if (_score >= 85) {
      return AppLocale.instance.currentCode == 'zh'
          ? '精彩的攻防转换！你精准避开了自辩与指责的本能陷阱，以极高维度的情绪容纳容器，让对方从刺猬防御自然软化。你已经具备资深心理咨询师级别的同理沟通本能。'
          : 'Impressive emotional agility! You skillfully navigated away from defensive justification and blame, creating a safe emotional container that softened their guard. You possess master-level empathetic intuition.';
    } else if (_score >= 70) {
      return AppLocale.instance.currentCode == 'zh'
          ? '整体沟通节奏稳健。你在接住情绪的同时尝试探寻事实，但偶尔稍显急躁。下一次可尝试在表达自己的观点前，先完全确认对方的需求已被彻底听见。'
          : 'Solid, grounded conversational pacing. You acknowledged feelings while exploring facts. Next time, try fully mirroring their emotional need before transitioning to practical steps.';
    } else {
      return AppLocale.instance.currentCode == 'zh'
          ? '在应对高压情绪时，人类本能容易诱发辩解或退缩。请记住：在对方防御值高于70%时，任何讲道理都会被知觉为指责。先接情绪，再谈事情。'
          : 'Under high emotional tension, our default instinct is to defend or withdraw. Remember: when emotional guard is above 70%, logic sounds like blame. Hold the emotion first, solve the issue second.';
    }
  }

  Widget _buildDimensionBar(String name, int score, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: score / 100.0,
                minHeight: 5,
                backgroundColor: AppColors.surfaceElevated,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$score',
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.borderLight, width: 1),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.warmBeige.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.warmBeige.withValues(alpha: 0.4), width: 0.8),
              ),
              child: Text(
                tr('round_settlement_title'),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.warmBeige,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Big Score
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$_score',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: AppColors.warmBeige,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  tr('score_unit'),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Text(
              _rankTitle,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.amberSand,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 14),

            // 4 Dimensions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSubtle, width: 0.8),
              ),
              child: Column(
                children: [
                  _buildDimensionBar(tr('dim_tolerance'), (_score * 0.95).round().clamp(50, 99), AppColors.empathyGreen),
                  _buildDimensionBar(tr('dim_insight'), (_score * 1.02).round().clamp(50, 99), AppColors.amberSand),
                  _buildDimensionBar(tr('dim_boundary'), (_score * 0.92).round().clamp(50, 99), AppColors.boundaryAmber),
                  _buildDimensionBar(tr('dim_agility'), (_score * 0.98).round().clamp(50, 99), AppColors.humorViolet),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Mentor feedback
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceHighlight.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSubtle, width: 0.6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.psychology_rounded, size: 14, color: AppColors.warmBeige),
                      const SizedBox(width: 5),
                      Text(
                        tr('mentor_tip'),
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.warmBeige,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _mentorComment,
                    style: const TextStyle(
                      fontSize: 11.5,
                      height: 1.45,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onRetry,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.borderLight),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(tr('retry'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onFinish,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.warmBeige,
                      foregroundColor: AppColors.background,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(tr('back_home'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
