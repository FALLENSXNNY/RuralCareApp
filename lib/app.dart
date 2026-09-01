import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers/app_providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/offline_banner.dart';

class RuralCareApp extends ConsumerWidget {
  const RuralCareApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // createAppRouter reads the AuthNotifier from Riverpod so GoRouter
    // re-evaluates the redirect callback on every auth state change.
    final router = createAppRouter(ref);
    final isOnline = ref.watch(isOnlineProvider);

    return MaterialApp.router(
      title: 'RuralCare',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
      builder: (context, child) {
        return Material(
          color: Colors.white,
          child: Column(
            children: [
              if (!isOnline)
                const SafeArea(
                  bottom: false,
                  child: OfflineBanner(
                    message:
                        'No internet connection — Emergency guidance remains available offline',
                  ),
                ),
              Expanded(child: child ?? const SizedBox.shrink()),
            ],
          ),
        );
      },
    );
  }
}
