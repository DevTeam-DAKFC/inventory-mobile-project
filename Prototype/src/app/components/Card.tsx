import { HTMLAttributes } from 'react';

interface CardProps extends HTMLAttributes<HTMLDivElement> {
  variant?: 'base' | 'elevated' | 'soft';
  padding?: 'none' | 'sm' | 'md' | 'lg';
  children: React.ReactNode;
}

export default function Card({
  variant = 'base',
  padding = 'md',
  children,
  className = '',
  ...props
}: CardProps) {
  const variantBg = {
    base: 'var(--surface-base)',
    elevated: 'var(--surface-elevated)',
    soft: 'var(--surface-soft)',
  };

  const paddingStyles = {
    none: '',
    sm: 'p-3',
    md: 'p-4',
    lg: 'p-5',
  };

  return (
    <div
      className={`rounded-xl border ${paddingStyles[padding]} ${className}`}
      style={{
        backgroundColor: variantBg[variant],
        borderColor: 'var(--border-subtle)',
      }}
      {...props}
    >
      {children}
    </div>
  );
}
