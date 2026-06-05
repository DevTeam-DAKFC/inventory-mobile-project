class AppRoutes {
  const AppRoutes._();

  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';

  static const home = '/home';
  static const products = '/products';
  static const stock = '/stock';
  static const movements = '/movements';
  static const alerts = '/alerts';
}

enum AppShellTab {
  home(AppRoutes.home),
  products(AppRoutes.products),
  stock(AppRoutes.stock),
  movements(AppRoutes.movements),
  alerts(AppRoutes.alerts);

  const AppShellTab(this.path);

  final String path;
}
