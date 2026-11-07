import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/journey/journey_store.dart';
import '../../../theme/konsena_colors.dart';
import '../../../theme/konsena_spacing.dart';
import '../../shared/widgets/konsena_buttons.dart';
import 'onboarding_slide.dart';

/// S01 — Welcome / Onboarding.
///
/// Visual rhythm follows `references/stitch/s01_onboarding/code.html`
/// (pale white→lavender surface, generous whitespace, visible `Lewati`,
/// rounded violet CTA). Deliberate differences:
///  * **three** approved slides (the reference shows four dots);
///  * no iOS status bar / home indicator;
///  * no external illustration URLs — illustrations are composed widgets.
///
/// Every path (skip and continue) leads to S02 `/privacy-setup`.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, required this.store});

  final JourneyStore store;

  /// Route every skip/continue path must reach (PAGE_BY_PAGE S01/S02).
  static const String routePath = '/welcome';
  static const String nextRoute = '/privacy-setup';

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _index = 0;

  bool get _isLast => _index >= kOnboardingSlides.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Marks onboarding as seen, then continues to S02.
  ///
  /// Called by both `Lewati` and the continue CTA so a skipped onboarding is
  /// not replayed on the next launch (PAGE_BY_PAGE S01: "setelah selesai tidak
  /// diulang kecuali user memilih ulang tutorial").
  Future<void> _continueToSetup() async {
    await widget.store.setOnboardingSeen();
    if (!mounted) return;
    context.go(OnboardingPage.nextRoute);
  }

  void _advance() {
    if (_isLast) {
      _continueToSetup();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KonsenaColors.cloudWhite,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              KonsenaColors.cloudWhite,
              KonsenaColors.white,
              KonsenaColors.paleLavender,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip action — always visible, always ≥48dp.
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: KonsenaSpacing.sm,
                    top: KonsenaSpacing.xxs,
                  ),
                  child: KonsenaTextAction(
                    label: 'Lewati',
                    semanticsLabel: 'Lewati onboarding',
                    color: KonsenaColors.textPrimary,
                    onPressed: _continueToSetup,
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: kOnboardingSlides.length,
                  onPageChanged: (value) => setState(() => _index = value),
                  itemBuilder: (context, position) => OnboardingSlideContent(
                    slide: kOnboardingSlides[position],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  KonsenaSpacing.xl,
                  KonsenaSpacing.sm,
                  KonsenaSpacing.xl,
                  KonsenaSpacing.md,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OnboardingDots(
                      index: _index,
                      count: kOnboardingSlides.length,
                    ),
                    KonsenaRoundCta(
                      onPressed: _advance,
                      icon: _isLast
                          ? Icons.check_rounded
                          : Icons.arrow_forward_rounded,
                      semanticsLabel: _isLast
                          ? 'Selesai dan lanjut ke pengaturan privasi'
                          : 'Selanjutnya, halaman ${_index + 2}',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
