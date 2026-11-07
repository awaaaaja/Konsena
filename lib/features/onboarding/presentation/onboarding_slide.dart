import 'package:flutter/material.dart';

import '../../../theme/konsena_colors.dart';
import '../../../theme/konsena_shadows.dart';
import '../../../theme/konsena_spacing.dart';

/// One onboarding message: illustration, headline, supporting copy.
class OnboardingSlide {
  const OnboardingSlide({
    required this.headline,
    required this.body,
    required this.icon,
    required this.illustrationLabel,
  });

  final String headline;
  final String body;
  final IconData icon;

  /// Accessibility label for the composed illustration ("semua ilustrasi
  /// berlabel ilustrasi" — PAGE_BY_PAGE S01).
  final String illustrationLabel;
}

/// The three approved onboarding messages (PAGE_BY_PAGE S01: pahami izin,
/// pindai kebijakan, tinjau bukti).
///
/// Slide 1 carries the mandated headline exactly as specified. The copy
/// describes product value only — no legal-compliance guarantee.
const List<OnboardingSlide> kOnboardingSlides = [
  OnboardingSlide(
    headline: 'Ubah Kebijakan Privasi yang Rumit Jadi Mudah Dipahami',
    body:
        'Lihat izin aplikasi dan kebijakan privasinya dalam ringkasan yang '
        'mudah dipahami, tanpa perlu jago hukum.',
    icon: Icons.shield_outlined,
    illustrationLabel: 'Ilustrasi perisai privasi',
  ),
  OnboardingSlide(
    headline: 'Siapkan Kebijakan untuk Ditinjau',
    body:
        'Impor dokumen dan pindai layar direncanakan. Fitur sumber belum aktif '
        'pada versi awal ini.',
    icon: Icons.document_scanner_outlined,
    illustrationLabel: 'Ilustrasi pemindaian dokumen',
  ),
  OnboardingSlide(
    headline: 'Tinjau Bukti Sebelum Menarik Kesimpulan',
    body:
        'Saat analisis tersedia, temuan akan merujuk ke sumber. Versi ini belum '
        'menampilkan temuan atau skor buatan.',
    icon: Icons.fact_check_outlined,
    illustrationLabel: 'Ilustrasi tinjauan bukti',
  ),
];

/// Composed illustration for a slide.
///
/// The Stitch reference loads external illustration URLs; those assets are
/// unlicensed and are deliberately NOT used. This widget rebuilds the visual
/// role (soft violet focal object on a pale lavender stage) from tokens.
class OnboardingIllustration extends StatelessWidget {
  const OnboardingIllustration({super.key, required this.slide});

  final OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: slide.illustrationLabel,
      child: ExcludeSemantics(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 220, maxWidth: 260),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ambient glow behind the object.
                Container(
                  width: 180,
                  height: 180,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: KonsenaColors.softLilac,
                  ),
                ),
                // Front card with the slide icon.
                Container(
                  width: 148,
                  height: 176,
                  decoration: BoxDecoration(
                    color: KonsenaColors.surface,
                    borderRadius: BorderRadius.circular(KonsenaRadii.hero),
                    border: Border.all(color: KonsenaColors.lavender),
                    boxShadow: KonsenaShadows.card,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: KonsenaGradients.hero,
                          borderRadius: BorderRadius.circular(
                            KonsenaRadii.card,
                          ),
                        ),
                        child: Icon(
                          slide.icon,
                          color: KonsenaColors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: KonsenaSpacing.md),
                      // Three placeholder "text" bars (decorative only).
                      for (final width in const [88.0, 64.0, 76.0])
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            width: width,
                            height: 8,
                            decoration: BoxDecoration(
                              color: KonsenaColors.paleLavender,
                              borderRadius: BorderRadius.circular(
                                KonsenaRadii.pill,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Text block of a slide (headline + body), scrollable by the page itself.
class OnboardingSlideContent extends StatelessWidget {
  const OnboardingSlideContent({super.key, required this.slide});

  final OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: KonsenaSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          OnboardingIllustration(slide: slide),
          const SizedBox(height: KonsenaSpacing.xl),
          Text(
            slide.headline,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(fontSize: 24),
          ),
          const SizedBox(height: KonsenaSpacing.sm),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Text(
              slide.body,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pagination indicator: elongated capsule for the active slide.
class OnboardingDots extends StatelessWidget {
  const OnboardingDots({super.key, required this.index, required this.count});

  final int index;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Langkah onboarding',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < count; i++)
            Padding(
              padding: const EdgeInsets.only(right: KonsenaSpacing.xs),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                width: i == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i == index
                      ? KonsenaColors.primary
                      : KonsenaColors.softLilac,
                  borderRadius: BorderRadius.circular(KonsenaRadii.pill),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
