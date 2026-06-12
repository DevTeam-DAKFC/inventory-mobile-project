import { ChevronDown } from 'lucide-react';

interface BranchSelectorProps {
  currentBranch: string;
  onChange?: () => void;
}

export default function BranchSelector({ currentBranch, onChange }: BranchSelectorProps) {
  return (
    <button
      onClick={onChange}
      className="flex items-center gap-2 px-3 py-2 rounded-lg border transition-colors"
      style={{
        backgroundColor: 'var(--surface-soft)',
        borderColor: 'var(--border-subtle)',
      }}
    >
      <span className="text-sm" style={{ color: 'var(--text-primary)' }}>
        {currentBranch}
      </span>
      <ChevronDown size={16} style={{ color: 'var(--text-muted)' }} />
    </button>
  );
}
