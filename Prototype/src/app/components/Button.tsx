import { ButtonHTMLAttributes } from 'react';
import { Loader2 } from 'lucide-react';

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'ghost';
  size?: 'sm' | 'md' | 'lg';
  loading?: boolean;
  fullWidth?: boolean;
}

export default function Button({
  children,
  variant = 'primary',
  size = 'md',
  loading = false,
  fullWidth = false,
  disabled,
  className = '',
  ...props
}: ButtonProps) {
  const baseStyles = 'inline-flex items-center justify-center gap-2 rounded-xl transition-all font-medium';

  const sizeStyles = {
    sm: 'h-9 px-4 text-sm',
    md: 'h-11 px-5',
    lg: 'h-12 px-6',
  };

  const variantStyles = {
    primary: 'text-[var(--app-bg)] shadow-sm',
    secondary: 'border shadow-sm',
    ghost: 'hover:bg-[var(--surface-soft)]',
  };

  const primaryBg = disabled || loading
    ? { backgroundColor: 'var(--surface-soft)', color: 'var(--text-muted)' }
    : { backgroundColor: 'var(--accent-primary)' };

  const secondaryBorder = {
    borderColor: 'var(--border-subtle)',
    color: 'var(--text-primary)',
    backgroundColor: 'var(--surface-base)',
  };

  const ghostColors = {
    color: 'var(--text-secondary)',
  };

  const style = variant === 'primary' ? primaryBg : variant === 'secondary' ? secondaryBorder : ghostColors;

  return (
    <button
      className={`${baseStyles} ${sizeStyles[size]} ${variantStyles[variant]} ${fullWidth ? 'w-full' : ''} ${className}`}
      disabled={disabled || loading}
      style={style}
      {...props}
    >
      {loading && <Loader2 size={16} className="animate-spin" />}
      {children}
    </button>
  );
}
