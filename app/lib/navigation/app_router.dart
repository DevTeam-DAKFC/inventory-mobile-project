import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../ui/auth/login_screen.dart';
import '../ui/auth/register_screen.dart';
import '../ui/alerts/alerts_screen.dart';
import '../ui/home/home_screen.dart';
import '../ui/movements/movement_form_screen.dart';
import '../ui/navigation/app_shell.dart';
import '../ui/navigation/not_found_screen.dart';
import '../ui/products/products_screen.dart';
import '../ui/products/product_detail_screen.dart';
import '../ui/products/product_form_screen.dart';
import '../ui/stock/stock_screen.dart';
import 'app_session.dart';
import 'routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(appSessionProvider);

  return buildAppRouter(session);
});

GoRouter buildAppRouter(
  AppSession session, {
  String initialLocation = AppRoutes.login,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    refreshListenable: session,
    redirect: (context, state) {
      final isPublicRoute = _publicRoutes.contains(state.matchedLocation);
      final isAuthenticated = session.isAuthenticated;

      if (!isAuthenticated && !isPublicRoute) {
        return AppRoutes.login;
      }

      if (isAuthenticated && isPublicRoute) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.products,
                builder: (context, state) => const ProductsScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (context, state) => const ProductFormScreen(),
                  ),
                  GoRoute(
                    path: ':productId',
                    builder: (context, state) => ProductDetailScreen(
                      productId: state.pathParameters['productId']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        builder: (context, state) => ProductFormScreen(
                          productId: state.pathParameters['productId'],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.stock,
                builder: (context, state) => const StockScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.movements,
                builder: (context, state) => const MovementFormScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.alerts,
                builder: (context, state) => const AlertsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => NotFoundScreen(location: state.uri.path),
  );
}

const _publicRoutes = {AppRoutes.login, AppRoutes.register};
