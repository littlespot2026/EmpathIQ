import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// High-performance GPU Canvas Painter for real-time harmonic fluid waves
class FluidBackgroundPainter extends CustomPainter {
  final double animationValue; // Continuous looping phase 0.0 -> 1.0
  final Offset? pointerPosition; // Interactive mouse position
  final double introProgress; // 0.0 (closed) -> 1.0 (fully opened)

  FluidBackgroundPainter({
    required this.animationValue,
    this.pointerPosition,
    this.introProgress = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final phase = animationValue * 2 * math.pi;

    // Layer 1: Ambient deep cosmic fluid backdrop
    final bgPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          math.sin(phase * 0.5) * 0.4,
          math.cos(phase * 0.4) * 0.3 - 0.2,
        ),
        radius: 1.4,
        colors: [
          const Color(0xFF161F30),
          const Color(0xFF0F1522),
          AppColors.background,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Layer 2: Deep Indigo & Violet Harmonic Fluid Ribbon
    _drawFluidWave(
      canvas: canvas,
      size: size,
      baseY: size.height * (0.35 + 0.15 * math.sin(phase * 0.6)),
      amplitude: 55 + 20 * math.sin(phase * 0.8),
      frequency: 0.004,
      phase: phase * 1.1,
      gradientColors: [
        const Color(0xFF6366F1).withValues(alpha: 0.18 * introProgress),
        const Color(0xFF8B5CF6).withValues(alpha: 0.10 * introProgress),
        Colors.transparent,
      ],
      isTopDown: true,
    );

    // Layer 3: Warm Amber & Gold Liquid Energy Wave
    _drawFluidWave(
      canvas: canvas,
      size: size,
      baseY: size.height * (0.60 + 0.12 * math.cos(phase * 0.7)),
      amplitude: 45 + 18 * math.cos(phase * 0.9),
      frequency: 0.005,
      phase: -phase * 0.9,
      gradientColors: [
        AppColors.warmBeige.withValues(alpha: 0.22 * introProgress),
        AppColors.amberSand.withValues(alpha: 0.14 * introProgress),
        Colors.transparent,
      ],
      isTopDown: false,
    );

    // Layer 4: Emotional Rose / Coral Fluid Crest
    _drawFluidWave(
      canvas: canvas,
      size: size,
      baseY: size.height * (0.80 + 0.08 * math.sin(phase * 0.5)),
      amplitude: 35 + 15 * math.sin(phase * 1.2),
      frequency: 0.006,
      phase: phase * 1.3,
      gradientColors: [
        const Color(0xFFF43F5E).withValues(alpha: 0.12 * introProgress),
        const Color(0xFFFB923C).withValues(alpha: 0.06 * introProgress),
        Colors.transparent,
      ],
      isTopDown: false,
    );

    // Interactive pointer ripple
    if (pointerPosition != null && introProgress > 0.5) {
      final ripplePaint = Paint()
        ..shader = RadialGradient(
          center: Alignment(
            (pointerPosition!.dx / size.width) * 2 - 1,
            (pointerPosition!.dy / size.height) * 2 - 1,
          ),
          radius: 0.35,
          colors: [
            AppColors.warmBeige.withValues(alpha: 0.12),
            AppColors.amberSand.withValues(alpha: 0.04),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      canvas.drawCircle(pointerPosition!, size.width * 0.25, ripplePaint);
    }
  }

  void _drawFluidWave({
    required Canvas canvas,
    required Size size,
    required double baseY,
    required double amplitude,
    required double frequency,
    required double phase,
    required List<Color> gradientColors,
    required bool isTopDown,
  }) {
    final path = Path();
    const step = 6.0;

    if (isTopDown) {
      path.moveTo(0, 0);
      path.lineTo(0, baseY);

      for (double x = 0; x <= size.width + step; x += step) {
        // Multi-frequency harmonic fluid wave
        final y = baseY +
            math.sin(x * frequency + phase) * amplitude +
            math.cos(x * frequency * 0.5 + phase * 0.7) * (amplitude * 0.45);
        path.lineTo(x, y);
      }

      path.lineTo(size.width, 0);
      path.close();
    } else {
      path.moveTo(0, size.height);
      path.lineTo(0, baseY);

      for (double x = 0; x <= size.width + step; x += step) {
        final y = baseY +
            math.sin(x * frequency + phase) * amplitude +
            math.cos(x * frequency * 0.6 - phase * 0.8) * (amplitude * 0.4);
        path.lineTo(x, y);
      }

      path.lineTo(size.width, size.height);
      path.close();
    }

    final wavePaint = Paint()
      ..shader = LinearGradient(
        begin: isTopDown ? Alignment.topCenter : Alignment.bottomCenter,
        end: isTopDown ? Alignment.bottomCenter : Alignment.topCenter,
        colors: gradientColors,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(covariant FluidBackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.introProgress != introProgress ||
        oldDelegate.pointerPosition != pointerPosition;
  }
}
