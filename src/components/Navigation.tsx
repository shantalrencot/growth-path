'use client'

import Link from 'next/link'
import { usePathname, useRouter } from 'next/navigation'
import { LogOut, BookOpen } from 'lucide-react'
import { cn } from '@/utils/helpers'
import { NAV_ITEMS, ROLE_LABELS } from '@/constants'
import { createClient } from '@/utils/supabase/client'
import type { Role } from '@/types'

interface NavigationProps {
  role:       Role
  memberName: string
}

export function Navigation({ role, memberName }: NavigationProps) {
  const pathname = usePathname()
  const router   = useRouter()
  const navItems = NAV_ITEMS[role]

  async function handleSignOut() {
    const supabase = createClient()
    await supabase.auth.signOut()
    router.push('/login')
    router.refresh()
  }

  return (
    <>
      {/* ── Desktop sidebar ── */}
      <aside className="hidden lg:flex lg:flex-col lg:w-60 lg:fixed lg:inset-y-0 lg:border-r lg:border-gray-200 lg:bg-white">
        <div className="flex items-center gap-2 px-6 py-5 border-b border-gray-200">
          <BookOpen className="h-6 w-6 text-brand-primary" />
          <span className="font-bold text-gray-900 text-sm">The Disciples</span>
        </div>

        <nav className="flex-1 px-3 py-4 space-y-1">
          {navItems.map((item) => (
            <Link
              key={item.href}
              href={item.href}
              className={cn(
                'flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium transition-colors',
                pathname === item.href || pathname.startsWith(item.href + '/')
                  ? 'bg-indigo-50 text-brand-primary'
                  : 'text-gray-600 hover:bg-gray-100'
              )}
            >
              {item.label}
            </Link>
          ))}
        </nav>

        <div className="border-t border-gray-200 px-4 py-4">
          <div className="flex items-center justify-between">
            <div className="min-w-0">
              <p className="truncate text-sm font-medium text-gray-900">{memberName}</p>
              <p className="text-xs text-gray-500">{ROLE_LABELS[role]}</p>
            </div>
            <button
              onClick={handleSignOut}
              className="ml-2 rounded-lg p-1.5 text-gray-400 hover:bg-gray-100 hover:text-gray-600"
              title="Sign out"
            >
              <LogOut className="h-4 w-4" />
            </button>
          </div>
        </div>
      </aside>

      {/* ── Mobile bottom nav ── */}
      <nav className="fixed bottom-0 left-0 right-0 z-50 flex border-t border-gray-200 bg-white lg:hidden">
        {navItems.slice(0, 4).map((item) => (
          <Link
            key={item.href}
            href={item.href}
            className={cn(
              'flex flex-1 flex-col items-center gap-0.5 py-2 text-xs font-medium transition-colors',
              pathname === item.href || pathname.startsWith(item.href + '/')
                ? 'text-brand-primary'
                : 'text-gray-500'
            )}
          >
            <span>{item.label}</span>
          </Link>
        ))}
      </nav>
    </>
  )
}
