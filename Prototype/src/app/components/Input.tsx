import { InputHTMLAttributes, forwardRef } from 'react';

interface InputProps extends InputHTMLAttributes<HTMLInputElement> {
  label?: string;
  error?: string;
}

const Input = forwardRef<HTMLInputElement, InputProps>(
  ({ label, error, className = '', ...props }, ref) => {
    return (
      <div className="flex flex-col gap-1.5">
        {label && (
          <label className="text-sm" style={{ color: 'var(--text-secondary)' }}>
            {label}
          </label>
        )}
        <input
          ref={ref}
          className={`h-11 px-4 rounded-xl border transition-colors ${className}`}
          style={{
            backgroundColor: 'var(--surface-soft)',
            borderColor: error ? 'var(--status-danger)' : 'var(--border-subtle)',
            color: 'var(--text-primary)',
          }}
          {...props}
        />
        {error && (
          <span className="text-xs" style={{ color: 'var(--status-danger)' }}>
            {error}
          </span>
        )}
      </div>
    );
  }
);

Input.displayName = 'Input';

export default Input;
