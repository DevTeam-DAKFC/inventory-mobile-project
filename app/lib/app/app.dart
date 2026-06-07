import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../navigation/app_router.dart';
import '../navigation/session_restore_controller.dart';
import '../ui/foundation/session_restore_screen.dart';
import 'theme.dart';

class InventoryMobileApp extends ConsumerWidget {
  const InventoryMobileApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restore = ref.watch(sessionRestoreProvider);

    return restore.when(
      loading: () => MaterialApp(
        title: 'Inventory Mobile',
        theme: buildAppTheme(),
        locale: const Locale('es'),
        supportedLocales: _supportedLocales,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        debugShowCheckedModeBanner: false,
        home: const SessionRestoreScreen(),
      ),
      error: (error, stackTrace) => MaterialApp(
        title: 'Inventory Mobile',
        theme: buildAppTheme(),
        locale: const Locale('es'),
        supportedLocales: _supportedLocales,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        debugShowCheckedModeBanner: false,
        home: _SessionRestoreErrorScreen(
          onRetry: () => ref.invalidate(sessionRestoreProvider),
        ),
      ),
      data: (_) {
        final router = ref.watch(appRouterProvider);
        return MaterialApp.router(
          title: 'Inventory Mobile',
          theme: buildAppTheme(),
          locale: const Locale('es'),
          supportedLocales: _supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          routerConfig: router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

const _supportedLocales = [Locale('es'), Locale('en')];

class _SessionRestoreErrorScreen extends StatelessWidget {
  const _SessionRestoreErrorScreen({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 56,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'No se pudo iniciar la aplicacion.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
