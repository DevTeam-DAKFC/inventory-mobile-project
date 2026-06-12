import { Outlet, NavLink, useLocation } from 'react-router';
import { Home, Package, Layers, TrendingUp, Bell } from 'lucide-react';

export default function MobileLayout() {
  const location = useLocation();

  const navItems = [
    { path: '/', icon: Home, label: 'Inicio' },
    { path: '/productos', icon: Package, label: 'Productos' },
    { path: '/stock', icon: Layers, label: 'Stock' },
    { path: '/movimientos', icon: TrendingUp, label: 'Movimientos' },
    { path: '/alertas', icon: Bell, label: 'Alertas' },
  ];

  const isActive = (path: string) => {
    if (path === '/') return location.pathname === '/';
    return location.pathname.startsWith(path);
  };

  return (
    <div className="flex flex-col h-screen max-w-md mx-auto bg-[var(--app-bg)]">
      <main className="flex-1 overflow-y-auto pb-20">
        <Outlet />
      </main>

      <nav
        className="fixed bottom-0 left-0 right-0 max-w-md mx-auto border-t"
        style={{
          backgroundColor: 'var(--surface-base)',
          borderColor: 'var(--border-subtle)',
        }}
      >
        <div className="flex items-center justify-around h-16 px-2">
          {navItems.map((item) => {
            const Icon = item.icon;
            const active = isActive(item.path);

            return (
              <NavLink
                key={item.path}
                to={item.path}
                className="flex flex-col items-center justify-center flex-1 h-full gap-0.5 transition-colors"
              >
                <Icon
                  size={20}
                  strokeWidth={active ? 2.5 : 2}
                  style={{ color: active ? 'var(--accent-primary)' : 'var(--text-muted)' }}
                />
                <span
                  className="text-[10px] leading-tight"
                  style={{
                    color: active ? 'var(--accent-primary)' : 'var(--text-muted)',
                    fontWeight: active ? 600 : 500,
                  }}
                >
                  {item.label}
                </span>
              </NavLink>
            );
          })}
        </div>
      </nav>
    </div>
  );
}
