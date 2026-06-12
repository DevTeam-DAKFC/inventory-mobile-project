interface BadgeProps {
  children: React.ReactNode;
  variant?: 'success' | 'warning' | 'danger' | 'info' | 'default';
  size?: 'sm' | 'md';
}

export default function Badge({ children, variant = 'default', size = 'sm' }: BadgeProps) {
  const sizeStyles = {
    sm: 'px-2 py-0.5 text-[10px]',
    md: 'px-2.5 py-1 text-xs',
  };

  const variantColors = {
    success: {
      backgroundColor: 'rgba(34, 197, 94, 0.14)',
      color: '#22C55E',
      border: '1px solid rgba(34, 197, 94, 0.2)',
    },
    warning: {
      backgroundColor: 'rgba(245, 158, 11, 0.14)',
      color: '#F59E0B',
      border: '1px solid rgba(245, 158, 11, 0.2)',
    },
    danger: {
      backgroundColor: 'rgba(239, 68, 68, 0.14)',
      color: '#EF4444',
      border: '1px solid rgba(239, 68, 68, 0.2)',
    },
    info: {
      backgroundColor: 'rgba(59, 130, 246, 0.14)',
      color: '#3B82F6',
      border: '1px solid rgba(59, 130, 246, 0.2)',
    },
    default: {
      backgroundColor: 'var(--accent-primary-soft)',
      color: 'var(--accent-primary)',
      border: '1px solid var(--border-active)',
    },
  };

  return (
    <span
      className={`inline-flex items-center rounded-full font-medium uppercase tracking-wide ${sizeStyles[size]}`}
      style={variantColors[variant]}
    >
      {children}
    </span>
  );
}
