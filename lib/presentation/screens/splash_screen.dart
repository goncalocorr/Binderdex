import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';

/// Ecrã de abertura: o logo aparece suavemente (pop-in + brilho) e o wordmark
/// "Binderdex" desliza; no fundo, discreto, "produced by hivecode".
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  late final Animation<double> _logoScale = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
  );
  late final Animation<double> _logoFade = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
  );
  late final Animation<double> _wordFade = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.45, 0.9, curve: Curves.easeOut),
  );
  late final Animation<Offset> _wordSlide = Tween(
    begin: const Offset(0, 0.4),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: _c,
    curve: const Interval(0.45, 0.95, curve: Curves.easeOutCubic),
  ));

  @override
  void initState() {
    super.initState();
    _c.forward();
    Timer(const Duration(milliseconds: 2300), () {
      if (mounted) context.go('/');
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.35),
            radius: 1.1,
            colors: [cs.primaryContainer, Theme.of(context).scaffoldBackgroundColor],
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: _logoScale,
                    child: FadeTransition(
                      opacity: _logoFade,
                      child: SvgPicture.asset('assets/logo-mark.svg',
                          width: 116, height: 116),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SlideTransition(
                    position: _wordSlide,
                    child: FadeTransition(
                      opacity: _wordFade,
                      child: Text.rich(
                        TextSpan(children: [
                          TextSpan(
                              text: 'Binder',
                              style: TextStyle(color: cs.primary)),
                          TextSpan(
                              text: 'dex',
                              style: TextStyle(color: cs.onSurface)),
                        ]),
                        style: TextStyle(
                          fontFamily: AppTheme.displayFont,
                          fontWeight: FontWeight.w700,
                          fontSize: 36,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Crédito discreto no fundo.
            Positioned(
              left: 0,
              right: 0,
              bottom: 28,
              child: FadeTransition(
                opacity: _wordFade,
                child: Text(
                  'produced by hivecode',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTheme.displayFont,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    letterSpacing: 1.2,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
