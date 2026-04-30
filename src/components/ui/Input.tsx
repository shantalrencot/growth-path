import { cn } from '@/utils/helpers'
import { type InputHTMLAttributes } from 'react'

interface InputProps extends InputHTMLAttributes<HTMLInputElement> {
  label?:   string
  error?:   string
  hint?:    string
}

export function Input({ label, error, hint, className, id, ...props }: InputProps) {
  const inputId = id ?? label?.toLowerCase().replace(/\s+/g, '-')
  return (
    <div className="space-y-1">
      {label && (
        <label htmlFor={inputId} className="block text-sm font-medium text-gray-700">
          {label}
        </label>
      )}
      <input
        id={inputId}
        className={cn(
          'block w-full rounded-lg border px-3 py-2 text-sm shadow-sm',
          'placeholder:text-gray-400 focus:outline-none focus:ring-2 focus:ring-brand-primary',
          error
            ? 'border-brand-danger focus:border-brand-danger focus:ring-brand-danger'
            : 'border-gray-300 focus:border-brand-primary',
          className
        )}
        {...props}
      />
      {error && <p className="text-xs text-brand-danger">{error}</p>}
      {hint && !error && <p className="text-xs text-gray-500">{hint}</p>}
    </div>
  )
}
