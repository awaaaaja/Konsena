import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/navigation/route_registry.dart';
import '../../../theme/konsena_colors.dart';
import '../../../theme/konsena_spacing.dart';
import 'home_cubit.dart';
import 'widgets/brand_header.dart';
import 'widgets/how_it_works_card.dart';
import 'widgets/hero_card.dart';
import 'widgets/local_status_card.dart';
import 'widgets/summary_section.dart';

/// S03 — Beranda / Home Dashboard.
///
/// Composition follows `references/stitch/01_dashboard/` (header wordmark,
/// dark hero with white `Mulai Audit`, two summary cards, 3-step education
/// card) rebuilt from approved tokens. Deliberate differences:
///  * no iOS status bar / home indicator and no bottom tab bar (the five-tab
///    shell arrives in Phase 01B together with its destinations);
///  * no `DEMO` badge and no `Sesi contoh` / `Analisis contoh` labels —
///    summary numbers come from [HomeSummaryRepository] state;
///  * no fake analysis figures anywhere.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  static const String routePath = '/home';

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    // Read the local summary once; a failure leaves the honest empty state.
    context.read<HomeCubit>().loadSummary();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: KonsenaColors.backgroundPage,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final horizontal = constraints.maxWidth <= 320
                    ? KonsenaSpacing.screenHorizontalCompact
                    : KonsenaSpacing.screenHorizontal;

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        horizontal,
                        KonsenaSpacing.md,
                        horizontal,
                        KonsenaSpacing.xxl,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          BrandHeader(isGuest: state.isGuest),
                          const SizedBox(height: KonsenaSpacing.md),
                          HeroAuditCard(
                            onStartAudit: () => context.go(
                              RouteRegistry.get(ScreenId.s24).path,
                            ),
                          ),
                          const SizedBox(height: KonsenaSpacing.xl),
                          SummarySection(
                            summary: state.summary,
                            isEmpty: state.summary.isEmpty,
                          ),
                          const SizedBox(height: KonsenaSpacing.xl),
                          const HowItWorksCard(),
                          const SizedBox(height: KonsenaSpacing.xl),
                          LocalStatusCard(state: state),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
