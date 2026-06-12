import { LucideIcon } from 'lucide-react';

interface EmptyStateProps {
  icon: LucideIcon;
  title: string;
  description?: string;
  action?: {
    label: string;
    onClick: () => void;
  };
}

export default function EmptyState({ icon: Icon, title, description, action }: EmptyStateProps) {
  return (
    <div className="flex flex-col items-center justify-center py-16 px-6 text-center">
      <div
        className="w-16 h-16 rounded-2xl flex items-center justify-center mb-4"
        style={{
          backgroundColor: 'var(--surface-soft)',
          border: '1px solid var(--border-subtle)',
        }}
      >
        <Icon size={28} style={{ color: 'var(--text-muted)' }} />
      </div>
      <h3 className="mb-2" style={{ color: 'var(--text-primary)' }}>
        {title}
      </h3>
      {description && (
        <p className="text-sm mb-4 max-w-xs" style={{ color: 'var(--text-secondary)' }}>
          {description}
        </p>
      )}
      {action && (
        <button
          onClick={action.onClick}
          className="px-4 py-2 rounded-lg text-sm"
          style={{
            backgroundColor: 'var(--accent-primary)',
            color: 'var(--app-bg)',
          }}
        >
          {action.label}
        </button>
      )}
    </div>
  );
}
