import { redirect } from 'next/navigation'
import { createClient } from '@/utils/supabase/server'
import { getMemberByAuthId } from '@/services/members'
import { Navigation } from '@/components/Navigation'
import type { Role } from '@/types'

export default async function DashboardLayout({ children }: { children: React.ReactNode }) {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()

  if (!user) redirect('/login')

  const member = await getMemberByAuthId(user.id).catch(() => null)
  if (!member) redirect('/login')

  const role = (member.roles?.name ?? 'disciple') as Role

  return (
    <div className="min-h-screen bg-gray-50">
      <Navigation role={role} memberName={member.name} />

      {/* Main content area — offset for desktop sidebar */}
      <main className="pb-20 lg:pb-0 lg:pl-60">
        <div className="mx-auto max-w-5xl px-4 py-6 sm:px-6">
          {children}
        </div>
      </main>
    </div>
  )
}
