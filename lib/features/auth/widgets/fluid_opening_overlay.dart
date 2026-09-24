import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/localization/app_locale.dart';
import '../../../core/theme/app_colors.dart';

class FluidOpeningOverlay extends StatelessWidget {
  final Animation<double> animation; // 0.0 -> 1.0
  final VoidCallback onDismiss;

  const FluidOpeningOverlay({
    super.key,
    required this.animation,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final progress = animation.value;
        if (progress >= 1.0) {
          return const SizedBox.shrink();
        }

        // Phase calculations:
        // 0.0 -> 0.4: Ripple bloom & logo arrival
        // 0.4 -> 0.75: Title glow & resonance
        // 0.75 -> 1.0: Fluid curtain expansion & fade out
        final logoOpacity = (progress / 0.35).clamp(0.0, 1.0);
        final titleOpacity = ((progress - 0.25) / 0.35).clamp(0.0, 1.0);
        final curtainScale = 1.0 + (progress > 0.65 ? (progress - 0.65) * 5.0 : 0.0);
        final overlayOpacity = (1.0 - ((progress - 0.7) / 0.3)).clamp(0.0, 1.0);

        return IgnorePointer(
          ignoring: progress >= 0.85,
          child: GestureDetector(
            onTap: onDismiss,
            behavior: HitTestBehavior.opaque,
            child: Opacity(
            opacity: overlayOpacity,
            child: Container(
              color: AppColors.background.withValues(alpha: 0.96),
              width: double.infinity,
              height: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Concentric liquid ripple shockwaves
                  CustomPaint(
                    size: MediaQuery.of(context).size,
                    painter: _OpeningRipplesPainter(
                      progress: progress,
                    ),
                  ),

                  // Center emblem and typography
                  Transform.scale(
                    scale: curtainScale,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Glowing fluid droplet logo container
                        Opacity(
                          opacity: logoOpacity,
                          child: Container(
                            width: 78,
                            height: 78,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.warmBeige,
                                  AppColors.amberSand,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.warmBeige.withValues(alpha: 0.6),
                                  blurRadius: 32 + (math.sin(progress * math.pi * 3) * 12),
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.psychology_rounded,
                              size: 42,
                              color: AppColors.background,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Title
                        Opacity(
                          opacity: titleOpacity,
                          child: Column(
                            children: [
                              const Text(
                                'EmpathIQ',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                  letterSpacing: 2.0,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                tr('app_slogan'),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.warmBeige,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom skip tip
                  Positioned(
                    bottom: 24,
                    child: Opacity(
                      opacity: (progress > 0.2 ? 0.6 : 0.0),
                      child: Text(
                        'Tap anywhere to skip',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
  }
}

class _OpeningRipplesPainter extends CustomPainter {
  final double progress;

  _OpeningRipplesPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.sqrt(size.width * size.width + size.height * size.height) * 0.7;

    // Ripple 1: Warm Gold
    final r1 = (progress * 1.6) * maxRadius;
    final alpha1 = (1.0 - (progress * 1.2)).clamp(0.0, 1.0) * 0.35;
    final paint1 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..color = AppColors.warmBeige.withValues(alpha: alpha1);
    canvas.drawCircle(center, r1, paint1);

    // Ripple 2: Electric Indigo
    final r2 = (math.max(0.0, progress - 0.15) * 1.5) * maxRadius;
    final alpha2 = (1.0 - (progress * 1.1)).clamp(0.0, 1.0) * 0.25;
    final paint2 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = const Color(0xFF6366F1).withValues(alpha: alpha2);
    canvas.drawCircle(center, r2, paint2);

    // Ripple 3: Soft Coral
    final r3 = (math.max(0.0, progress - 0.3) * 1.4) * maxRadius;
    final alpha3 = (1.0 - (progress * 1.0)).clamp(0.0, 1.0) * 0.2;
    final paint3 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = const Color(0xFFF43F5E).withValues(alpha: alpha3);
    canvas.drawCircle(center, r3, paint3);
  }

  @override
  bool shouldRepaint(covariant _OpeningRipplesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
