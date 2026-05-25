import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class DecorativeBackground extends StatelessWidget {
  final Widget child;
  final bool showTopDecoration;
  final bool showBottomDecoration;

  const DecorativeBackground({
    super.key,
    required this.child,
    this.showTopDecoration = true,
    this.showBottomDecoration = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        if (showTopDecoration)
          Positioned(
            top: -120,
            right: -80,
            child: _CircleDecoration(
              size: 320,
              color: isDark
                  ? AppColors.primaryDark.withAlpha(20)
                  : AppColors.primary.withAlpha(12),
            ),
          ),
        if (showTopDecoration)
          Positioned(
            top: -40,
            left: -60,
            child: _CircleDecoration(
              size: 200,
              color: isDark
                  ? AppColors.gold.withAlpha(15)
                  : AppColors.gold.withAlpha(10),
            ),
          ),
        if (showBottomDecoration)
          Positioned(
            bottom: -100,
            left: -80,
            child: _CircleDecoration(
              size: 280,
              color: isDark
                  ? AppColors.primaryDark.withAlpha(15)
                  : AppColors.primary.withAlpha(8),
            ),
          ),
        if (showBottomDecoration)
          Positioned(
            bottom: -30,
            right: -40,
            child: _CircleDecoration(
              size: 180,
              color: isDark
                  ? AppColors.gold.withAlpha(12)
                  : AppColors.gold.withAlpha(8),
            ),
          ),
        Positioned(
          top: 60,
          right: 40,
          child: _DotPattern(
            color: isDark
                ? AppColors.primaryDark.withAlpha(15)
                : AppColors.primary.withAlpha(10),
          ),
        ),
        child,
      ],
    );
  }
}

class _CircleDecoration extends StatelessWidget {
  final double size;
  final Color color;

  const _CircleDecoration({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class _DotPattern extends StatelessWidget {
  final Color color;

  const _DotPattern({required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(60, 60),
      painter: _DotPatternPainter(color: color),
    );
  }
}

class _DotPatternPainter extends CustomPainter {
  final Color color;

  _DotPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final random = Random(42);
    final spacing = 15.0;

    for (double x = spacing / 2; x < size.width; x += spacing) {
      for (double y = spacing / 2; y < size.height; y += spacing) {
        if (random.nextDouble() > 0.4) {
          canvas.drawCircle(
            Offset(x, y),
            1.5 + random.nextDouble() * 1.5,
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final bool showBorder;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.height,
    this.width,
    this.borderRadius,
    this.boxShadow,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: height,
      width: width,
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.glassDark : AppColors.glassWhite,
        borderRadius: borderRadius ?? BorderRadius.circular(24),
        border: showBorder
            ? Border.all(
                color: (isDark ? Colors.white : Colors.white).withAlpha(30),
                width: 0.5,
              )
            : null,
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: Colors.black.withAlpha(16),
            blurRadius: 28,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}
