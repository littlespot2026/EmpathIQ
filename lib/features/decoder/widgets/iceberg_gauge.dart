import 'package:flutter/material.dart';
import '../../../core/models/decode_result.dart';
import '../../../core/theme/app_colors.dart';

class IcebergGauge extends StatelessWidget {
  final DecodeResult result;

  const IcebergGauge({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final temp = result.temperature;
    final tempColor = AppColors.getTemperatureColor(temp);
    final defense = result.defensePercent;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Temperature & Defense Gauges
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Temperature circle badge
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        tempColor,
                        tempColor.withValues(alpha: 0.7),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: tempColor.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$temp°',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          result.temperatureLevel,
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Meters column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Temperature progress bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '情绪温度指数',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            result.temperatureLevel,
                            style: TextStyle(
                              fontSize: 12,
                              color: tempColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: (temp / 100.0).clamp(0.0, 1.0),
                          minHeight: 6,
                          backgroundColor: AppColors.surfaceElevated,
                          valueColor: AlwaysStoppedAnimation<Color>(tempColor),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Defense percentage bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '心理心防 / 戒备度',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '$defense%',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFA78BFA),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: (defense / 100.0).clamp(0.0, 1.0),
                          minHeight: 6,
                          backgroundColor: AppColors.surfaceElevated,
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFA78BFA)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Iceberg Visual Divider (Surface vs Submerged)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              border: const Border(
                top: BorderSide(color: AppColors.borderSubtle, width: 0.8),
                bottom: BorderSide(color: AppColors.borderSubtle, width: 0.8),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.waves_rounded,
                  size: 16,
                  color: AppColors.coldBlue,
                ),
                const SizedBox(width: 6),
                const Text(
                  '情绪冰山水面线 (表层伪装 vs 深层暗涌)',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),

          // Submerged psychological insights
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Surface wording
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.borderLight, width: 0.6),
                      ),
                      child: const Text(
                        '表面陈述',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '“${result.surfaceMeaning}”',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Real subtext (Highlighted)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warmBeige.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.warmBeige.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.visibility_rounded,
                            size: 15,
                            color: AppColors.amberSand,
                          ),
                          SizedBox(width: 6),
                          Text(
                            '真实潜台词（真实心理动机）',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.amberSand,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        result.realSubtext,
                        style: const TextStyle(
                          fontSize: 13.5,
                          height: 1.45,
                          fontWeight: FontWeight.w600,
                          color: AppColors.warmBeigeLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Core pain point
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.crisis_alert_rounded,
                      size: 15,
                      color: AppColors.flammableRed,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 12.5, height: 1.4),
                          children: [
                            const TextSpan(
                              text: '核心痛点：',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFFCA5A5),
                              ),
                            ),
                            TextSpan(
                              text: result.corePainPoint,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
