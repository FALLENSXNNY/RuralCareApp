import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/localization/app_localizations.dart';
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
    final currentLocale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'RuralCare',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
      locale: currentLocale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return Material(
          color: Colors.white,
          child: Column(
            children: [
              if (!isOnline)
                SafeArea(
                  bottom: false,
                  child: OfflineBanner(
                    message: context.l10n.offlineBannerMsg,
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
