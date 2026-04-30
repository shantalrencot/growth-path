import { getInitials, cn } from '@/utils/helpers'

interface AvatarProps {
  name:       string
  size?:      'sm' | 'md' | 'lg'
  className?: string
}

const sizes = {
  sm: 'h-8 w-8 text-xs',
  md: 'h-10 w-10 text-sm',
  lg: 'h-14 w-14 text-lg',
}

export function Avatar({ name, size = 'md', className }: AvatarProps) {
  return (
    <div
      className={cn(
        'flex items-center justify-center rounded-full bg-brand-primary font-semibold text-white',
        sizes[size],
        className
      )}
    >
      {getInitials(name)}
    </div>
  )
}
