import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/providers/settings_provider.dart';
import 'onboarding_screen.dart';
import '../../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoCtrl;
  late final AnimationController _textCtrl;
  late final AnimationController _subtitleCtrl;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _subtitleOpacity;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutBack));
    _logoOpacity = CurvedAnimation(parent: _logoCtrl, curve: Curves.easeIn);

    _textCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _textOpacity = CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn);
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));

    _subtitleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _subtitleOpacity =
        CurvedAnimation(parent: _subtitleCtrl, curve: Curves.easeIn);

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _textCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _subtitleCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    _navigate();
  }

  void _navigate() {
    final settings = context.read<SettingsProvider>();
    final dest = settings.isOnboarded
        ? const AppShell() as Widget
        : const OnboardingScreen();
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => dest,
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: a, child: child),
      ),
      (_) => false,
    );
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _subtitleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradColors = isDark
        ? [const Color(0xFF001A14), const Color(0xFF003328), const Color(0xFF004337)]
        : [const Color(0xFF003328), const Color(0xFF004337), const Color(0xFF0F5C4D)];

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradColors,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),

              // Logo
              AnimatedBuilder(
                animation: _logoCtrl,
                builder: (_, child) => Opacity(
                  opacity: _logoOpacity.value,
                  child: Transform.scale(scale: _logoScale.value, child: child),
                ),
                child: Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withAlpha(18),
                    border: Border.all(color: Colors.white.withAlpha(30), width: 1.5),
                    boxShadow: [
                      BoxShadow(color: AppColors.goldenAccent.withAlpha(40),
                          blurRadius: 40, spreadRadius: 8),
                    ],
                  ),
                  child: ShaderMask(
                    shaderCallback: (r) => const LinearGradient(
                      colors: [AppColors.goldenAccent, Color(0xFFFFF3D6)],
                    ).createShader(r),
                    child: const Icon(Icons.auto_awesome_rounded,
                        size: 56, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Arabic title
              SlideTransition(
                position: _textSlide,
                child: FadeTransition(
                  opacity: _textOpacity,
                  child: Text('نور',
                      style: AppTypography.arabicDisplay.copyWith(
                          color: Colors.white, fontSize: 52),
                      textDirection: TextDirection.rtl),
                ),
              ),
              const SizedBox(height: 4),

              // English subtitle
              SlideTransition(
                position: _textSlide,
                child: FadeTransition(
                  opacity: _textOpacity,
                  child: Text('NOOR ATHKAR',
                      style: AppTypography.labelLarge.copyWith(
                          color: Colors.white.withAlpha(180),
                          letterSpacing: 6, fontSize: 14)),
                ),
              ),

              const SizedBox(height: 24),

              // Tagline
              FadeTransition(
                opacity: _subtitleOpacity,
                child: Text('أذكارك اليومية في مكان واحد',
                    style: AppTypography.arabicBody.copyWith(
                        color: AppColors.goldenAccent.withAlpha(200),
                        fontSize: 18),
                    textDirection: TextDirection.rtl),
              ),

              const Spacer(flex: 3),

              // Bottom ornament
              FadeTransition(
                opacity: _subtitleOpacity,
                child: Container(
                  width: 48, height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.goldenAccent.withAlpha(100),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
