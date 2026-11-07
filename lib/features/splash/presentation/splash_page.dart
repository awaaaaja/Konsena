import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/journey/journey_store.dart';
import '../../../theme/konsena_colors.dart';
import '../../../theme/konsena_shadows.dart';
import '../../../theme/konsena_spacing.dart';
import '../../../theme/konsena_typography.dart';
import '../../shared/widgets/konsena_buttons.dart';
import 'splash_cubit.dart';

/// Wires a [SplashCubit] to the S00 page.
///
/// The store is injected so tests can drive first-run, returning-user and
/// failing-storage scenarios without any platform channel.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key, required this.store});

  final JourneyStore store;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SplashCubit>(
      create: (_) => SplashCubit(store)..start(),
      child: const SplashPage(),
    );
  }
}

/// S00 — Splash Screen.
///
/// Composition follows `references/stitch/s00_splash_screen/code.html`:
/// dark radial violet atmosphere, transparent KONSENA emblem, app name,
/// tagline and a minimal loading indicator. Deliberate differences:
///  * no iOS status bar / home indicator (Android-first),
///  * no OS permission prompt,
///  * real loading/failed bootstrap states instead of a fake progress demo.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  /// App entry route (first screen after launch).
  static const String initialRoute = '/splash';

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loadingController;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
  }

  @override
  void dispose() {
    _loadingController.stop();
    _loadingController.dispose();
    super.dispose();
  }

  void _onState(BuildContext context, SplashState state) {
    if (state.status == SplashStatus.loading) {
      if (!_loadingController.isAnimating) _loadingController.repeat();
    } else {
      _loadingController.stop();
    }
    if (state.status == SplashStatus.ready && state.destination != null) {
      context.go(state.destination!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SplashCubit, SplashState>(
      listener: _onState,
      builder: (context, state) {
        final theme = Theme.of(context);

        return AnnotatedRegion<SystemUiOverlayStyle>(
          // Light system icons: the splash scaffold is dark.
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            backgroundColor: KonsenaColors.midnightPurple,
            body: Stack(
              fit: StackFit.expand,
              children: [
                // Radial violet glow over the Midnight Purple base.
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: KonsenaGradients.splashGlow,
                  ),
                ),
                // Curved planetary horizon crest at the bottom.
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: _PlanetaryHorizon(),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: KonsenaSpacing.xl,
                    ),
                    child: Column(
                      children: [
                        const Spacer(),
                        const _Emblem(),
                        const SizedBox(height: KonsenaSpacing.xl),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: KonsenaTypography.style(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                              color: KonsenaColors.cloudWhite,
                            ),
                            children: [
                              const TextSpan(text: 'Konsena '),
                              TextSpan(
                                text: 'AI',
                                style: KonsenaTypography.style(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  color: KonsenaColors.paleLavender,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: KonsenaSpacing.sm),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 270),
                          child: Text(
                            'Pahami, Kendalikan, dan Lindungi Data Pribadimu',
                            textAlign: TextAlign.center,
                            style: KonsenaTypography.style(
                              fontSize: 14,
                              height: 1.5,
                              color: KonsenaColors.cloudWhite,
                            ).copyWith(letterSpacing: 0.2),
                          ),
                        ),
                        const Spacer(),
                        _StatusArea(
                          state: state,
                          loadingController: _loadingController,
                          theme: theme,
                        ),
                        const SizedBox(height: KonsenaSpacing.xl),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Transparent brand emblem on the dark splash canvas.
class _Emblem extends StatelessWidget {
  const _Emblem();

  static const String assetPath = 'assets/brand/konsena_mark_transparent.png';

  @override
  Widget build(BuildContext context) {
    final emblem = Image.asset(
      assetPath,
      width: 132,
      height: 132,
      fit: BoxFit.contain,
      // The PNG is RGBA with transparent background (verified in Phase 01A
      // READ); no color backdrop is painted behind it on either canvas.
      errorBuilder: (context, error, stackTrace) => const Icon(
        Icons.verified_user_outlined,
        size: 96,
        color: KonsenaColors.paleLavender,
      ),
    );

    return Semantics(
      image: true,
      label: 'Logo KONSENA AI',
      child: ExcludeSemantics(child: emblem),
    );
  }
}

/// Loading / failed bootstrap area (bottom of the splash).
class _StatusArea extends StatelessWidget {
  const _StatusArea({
    required this.state,
    required this.loadingController,
    required this.theme,
  });

  final SplashState state;
  final AnimationController loadingController;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case SplashStatus.loading:
        return Semantics(
          liveRegion: true,
          label: 'Menyiapkan data lokal',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LoadingBar(controller: loadingController),
              const SizedBox(height: KonsenaSpacing.sm),
              Text(
                'Menyiapkan data lokal…',
                style: KonsenaTypography.style(
                  fontSize: 12,
                  color: KonsenaColors.cloudWhite,
                ),
              ),
            ],
          ),
        );
      case SplashStatus.ready:
        return const SizedBox(height: KonsenaTouch.minTarget);
      case SplashStatus.failed:
        return Semantics(
          liveRegion: true,
          label: 'Gagal memulai aplikasi',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: KonsenaColors.warningAmber,
                size: 28,
              ),
              const SizedBox(height: KonsenaSpacing.xs),
              Text(
                'Gagal memulai aplikasi',
                textAlign: TextAlign.center,
                style: KonsenaTypography.style(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: KonsenaColors.cloudWhite,
                ),
              ),
              const SizedBox(height: KonsenaSpacing.xxs),
              Text(
                state.diagnostic ?? 'gagal_membaca_lokal',
                textAlign: TextAlign.center,
                style: KonsenaTypography.style(
                  fontSize: 11,
                  color: KonsenaColors.lavender,
                ),
              ),
              const SizedBox(height: KonsenaSpacing.sm),
              KonsenaOnDarkButton(
                label: 'Coba lagi',
                icon: Icons.refresh_rounded,
                onPressed: () => context.read<SplashCubit>().retry(),
              ),
            ],
          ),
        );
    }
  }
}

/// Minimal sliding progress bar (reference: `progressLoading` keyframes).
class _LoadingBar extends StatelessWidget {
  const _LoadingBar({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Memuat',
      value: 'Memuat',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          const height = 4.0;
          final barWidth = totalWidth * 0.6;

          return SizedBox(
            width: totalWidth,
            height: height,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(KonsenaRadii.pill),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: KonsenaColors.cloudWhite.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(KonsenaRadii.pill),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: controller,
                    builder: (context, child) {
                      final t = controller.value;
                      final dx = -barWidth + t * (totalWidth + barWidth);
                      return Transform.translate(
                        offset: Offset(dx, 0),
                        child: child,
                      );
                    },
                    child: Container(
                      width: barWidth,
                      height: height,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            KonsenaColors.paleLavender,
                            KonsenaColors.white,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Curved horizon glow at the bottom of the splash (Stitch
/// `planetary-horizon`, rebuilt with approved tokens and no fake chrome).
class _PlanetaryHorizon extends StatelessWidget {
  const _PlanetaryHorizon();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        height: 200,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Transform.translate(
            offset: const Offset(0, 120),
            child: Container(
              width: 520,
              height: 320,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: KonsenaGradients.planetaryHorizon,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x667838D8),
                    offset: Offset(0, -12),
                    blurRadius: 48,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
