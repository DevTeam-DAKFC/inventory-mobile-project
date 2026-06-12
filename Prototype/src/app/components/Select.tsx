import { SelectHTMLAttributes, forwardRef } from 'react';

interface SelectProps extends SelectHTMLAttributes<HTMLSelectElement> {
  label?: string;
  error?: string;
}

const Select = forwardRef<HTMLSelectElement, SelectProps>(
  ({ label, error, className = '', children, ...props }, ref) => {
    return (
      <div className="flex flex-col gap-1.5">
        {label && (
          <label className="text-sm" style={{ color: 'var(--text-secondary)' }}>
            {label}
          </label>
        )}
        <select
          ref={ref}
          className={`h-11 px-4 rounded-xl border transition-colors ${className}`}
          style={{
            backgroundColor: 'var(--surface-soft)',
            borderColor: error ? 'var(--status-danger)' : 'var(--border-subtle)',
            color: 'var(--text-primary)',
          }}
          {...props}
        >
          {children}
        </select>
        {error && (
          <span className="text-xs" style={{ color: 'var(--status-danger)' }}>
            {error}
          </span>
        )}
      </div>
    );
  }
);

Select.displayName = 'Select';

export default Select;
