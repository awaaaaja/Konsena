import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/supabase/cloud_gateway.dart';
import '../features/home/presentation/home_cubit.dart';
import 'app_router.dart';

/// Root widget of KONSENA AI.
///
/// The [CloudGateway] is injected rather than read from the service locator so
/// widget tests can drive both branches (guest vs configured) without any
/// network or plugin channel.
class KonsenaApp extends StatefulWidget {
  const KonsenaApp({super.key, required this.cloudGateway, this.router});

  final CloudGateway cloudGateway;

  /// Test seam; when null the app owns and disposes its own router.
  final GoRouter? router;

  @override
  State<KonsenaApp> createState() => _KonsenaAppState();
}

class _KonsenaAppState extends State<KonsenaApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = widget.router ?? createAppRouter();
  }

  @override
  void dispose() {
    if (widget.router == null) {
      _router.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeCubit>(
      create: (_) => HomeCubit(widget.cloudGateway),
      child: MaterialApp.router(
        title: 'KONSENA AI',
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF5A3DAD), // Royal Violet
            primary: const Color(0xFF5A3DAD),
            secondary: const Color(0xFF7838D8), // Electric Violet
            surface: const Color(0xFFfdfcfe), // Cloud White
          ),
          scaffoldBackgroundColor: const Color(0xFFfdfcfe),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: false,
            foregroundColor: Color(0xFF252148), // Midnight Purple
            backgroundColor: Color(0xFFfdfcfe),
            titleTextStyle: TextStyle(
              color: Color(0xFF252148),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          textTheme: const TextTheme(
            headlineMedium: TextStyle(
              color: Color(0xFF252148),
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
            titleSmall: TextStyle(
              color: Color(0xFF252148),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            bodyMedium: TextStyle(color: Color(0xFF342D61), fontSize: 14),
            bodySmall: TextStyle(color: Color(0xFF342D61), fontSize: 12),
          ),
        ),
      ),
    );
  }
}
