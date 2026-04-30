import { cn } from '@/utils/helpers'

interface ProgressBarProps {
  value:      number
  label?:     string
  showLabel?: boolean
  size?:      'sm' | 'md'
  color?:     'indigo' | 'green' | 'amber'
}

const trackColors = {
  indigo: 'bg-brand-primary',
  green:  'bg-brand-success',
  amber:  'bg-brand-accent',
}

const heights = { sm: 'h-1.5', md: 'h-2.5' }

export function ProgressBar({
  value,
  label,
  showLabel = true,
  size = 'md',
  color = 'indigo',
}: ProgressBarProps) {
  const pct = Math.min(100, Math.max(0, value))
  return (
    <div className="w-full">
      {(label || showLabel) && (
        <div className="mb-1 flex justify-between text-xs text-gray-600">
          {label && <span>{label}</span>}
          {showLabel && <span>{pct}%</span>}
        </div>
      )}
      <div className={cn('w-full rounded-full bg-gray-200', heights[size])}>
        <div
          className={cn('rounded-full transition-all duration-300', heights[size], trackColors[color])}
          style={{ width: `${pct}%` }}
        />
      </div>
    </div>
  )
}
