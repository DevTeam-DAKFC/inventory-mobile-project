import { TextareaHTMLAttributes, forwardRef } from 'react';

interface TextareaProps extends TextareaHTMLAttributes<HTMLTextAreaElement> {
  label?: string;
  error?: string;
}

const Textarea = forwardRef<HTMLTextAreaElement, TextareaProps>(
  ({ label, error, className = '', ...props }, ref) => {
    return (
      <div className="flex flex-col gap-1.5">
        {label && (
          <label className="text-sm" style={{ color: 'var(--text-secondary)' }}>
            {label}
          </label>
        )}
        <textarea
          ref={ref}
          className={`px-4 py-3 rounded-xl border resize-none transition-colors ${className}`}
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

Textarea.displayName = 'Textarea';

export default Textarea;
