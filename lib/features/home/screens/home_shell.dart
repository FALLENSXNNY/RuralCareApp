import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/router/app_router.dart';

/// Bottom navigation shell — wraps all main patient tabs.
/// Dynamically shows the Pregnancy tab only for female pregnant patients.
class HomeShell extends ConsumerWidget {
  const HomeShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientAsync = ref.watch(currentPatientProvider);
    final cached = () {
      try {
        return ref.read(localStorageProvider).patientProfile;
      } catch (_) {
        return null;
      }
    }();
    final patient = patientAsync.valueOrNull ?? cached;
    final isPregnant = patient != null &&
        patient.gender.toLowerCase() == 'female' &&
        patient.isPregnant;

    String location = '/home';
    try {
      location = GoRouterState.of(context).uri.toString();
    } catch (_) {}
    final l10n = context.l10n;

    // Dynamic destinations list
    final destinations = <NavigationDestination>[
      NavigationDestination(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home),
        label: l10n.navHome,
      ),
      if (isPregnant)
        NavigationDestination(
          icon: const Icon(Icons.pregnant_woman_outlined),
          selectedIcon: const Icon(Icons.pregnant_woman),
          label: l10n.navPregnancy,
        ),
      NavigationDestination(
        icon: const Icon(Icons.local_hospital_outlined),
        selectedIcon: const Icon(Icons.local_hospital),
        label: l10n.navFindCare,
      ),
      NavigationDestination(
        icon: const Icon(Icons.folder_outlined),
        selectedIcon: const Icon(Icons.folder),
        label: l10n.navRecords,
      ),
      NavigationDestination(
        icon: const Icon(Icons.chat_bubble_outline),
        selectedIcon: const Icon(Icons.chat_bubble),
        label: l10n.navAiAssistant,
      ),
    ];

    // Compute active index based on current location and dynamic tab presence
    int selectedIndex = 0;
    if (isPregnant) {
      if (location.startsWith('/pregnancy')) {
        selectedIndex = 1;
      } else if (location.startsWith('/find-care') || location.startsWith('/care')) {
        selectedIndex = 2;
      } else if (location.startsWith('/records')) {
        selectedIndex = 3;
      } else if (location.startsWith('/ai-chat')) {
        selectedIndex = 4;
      } else {
        selectedIndex = 0; // home
      }
    } else {
      if (location.startsWith('/find-care') || location.startsWith('/care')) {
        selectedIndex = 1;
      } else if (location.startsWith('/records')) {
        selectedIndex = 2;
      } else if (location.startsWith('/ai-chat')) {
        selectedIndex = 3;
      } else {
        selectedIndex = 0; // home
      }
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex.clamp(0, destinations.length - 1),
        onDestinationSelected: (i) {
          if (isPregnant) {
            switch (i) {
              case 0:
                context.go(AppRoutes.home);
                break;
              case 1:
                context.go(AppRoutes.pregnancy);
                break;
              case 2:
                context.go(AppRoutes.facilityFinder);
                break;
              case 3:
                context.go(AppRoutes.recordsHub);
                break;
              case 4:
                context.go(AppRoutes.aiChat);
                break;
            }
          } else {
            switch (i) {
              case 0:
                context.go(AppRoutes.home);
                break;
              case 1:
                context.go(AppRoutes.facilityFinder);
                break;
              case 2:
                context.go(AppRoutes.recordsHub);
                break;
              case 3:
                context.go(AppRoutes.aiChat);
                break;
            }
          }
        },
        destinations: destinations,
      ),
    );
  }
}
