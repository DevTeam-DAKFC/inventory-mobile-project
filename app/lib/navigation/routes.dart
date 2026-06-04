class AppRoutes {
  const AppRoutes._();

  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';

  static const home = '/home';
  static const products = '/products';
  static const productImport = '/products/import';
  static const stock = '/stock';
  static const movementNew = '/movements/new';
  static const history = '/history';
  static const notifications = '/notifications';
  static const settings = '/settings';
}

enum AppShellTab {
  home(AppRoutes.home),
  products(AppRoutes.products),
  stock(AppRoutes.stock),
  history(AppRoutes.history);

  const AppShellTab(this.path);

  final String path;
}
