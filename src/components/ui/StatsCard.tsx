import { type LucideIcon } from 'lucide-react'
import { cn } from '@/utils/helpers'

interface StatsCardProps {
  label:      string
  value:      string | number
  icon:       LucideIcon
  trend?:     string
  color?:     'indigo' | 'amber' | 'green' | 'red'
}

const colors = {
  indigo: 'bg-indigo-50 text-brand-primary',
  amber:  'bg-amber-50 text-brand-accent',
  green:  'bg-green-50 text-brand-success',
  red:    'bg-red-50 text-brand-danger',
}

export function StatsCard({ label, value, icon: Icon, trend, color = 'indigo' }: StatsCardProps) {
  return (
    <div className="rounded-xl border border-gray-200 bg-white p-5 shadow-sm">
      <div className="flex items-start justify-between">
        <div>
          <p className="text-sm text-gray-500">{label}</p>
          <p className="mt-1 text-2xl font-bold text-gray-900">{value}</p>
          {trend && <p className="mt-1 text-xs text-gray-500">{trend}</p>}
        </div>
        <div className={cn('rounded-lg p-2.5', colors[color])}>
          <Icon className="h-5 w-5" />
        </div>
      </div>
    </div>
  )
}
