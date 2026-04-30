import { redirect } from 'next/navigation'
import { Calendar } from 'lucide-react'
import { createClient } from '@/utils/supabase/server'
import { getMemberByAuthId } from '@/services/members'
import { getMeetingsByGroup } from '@/services/meetings'
import { getGroupsByDiscipler, getGroupsByMembership } from '@/services/groups'
import { Card } from '@/components/ui/Card'
import { Badge } from '@/components/ui/Badge'
import { EmptyState } from '@/components/ui/EmptyState'
import { formatDateTime } from '@/utils/helpers'

export default async function MeetingsPage() {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) redirect('/login')

  const member = await getMemberByAuthId(user.id)
  if (!member) redirect('/login')

  const role = member.roles?.name

  const groups = role === 'disciple'
    ? await getGroupsByMembership(member.id)
    : await getGroupsByDiscipler(member.id)

  const allMeetings = (
    await Promise.all(groups.map((g) => getMeetingsByGroup(g.id)))
  ).flat().sort((a, b) => new Date(b.scheduled_at).getTime() - new Date(a.scheduled_at).getTime())

  return (
    <div className="space-y-4">
      <h1 className="text-xl font-bold text-gray-900">Meetings</h1>

      {allMeetings.length === 0 ? (
        <EmptyState
          icon={Calendar}
          title="No meetings yet"
          description={role === 'disciple' ? 'Your group meetings will appear here.' : 'Schedule a meeting for one of your groups.'}
        />
      ) : (
        <div className="space-y-2">
          {allMeetings.map((m) => {
            const total    = m.attendance?.length ?? 0
            const attended = m.attendance?.filter((a) => a.attended).length ?? 0
            const isPast   = new Date(m.scheduled_at) < new Date()
            return (
              <Card key={m.id}>
                <div className="flex justify-between items-start">
                  <div>
                    <p className="font-medium text-gray-900">{m.title ?? 'Group Meeting'}</p>
                    <p className="text-xs text-gray-500">{formatDateTime(m.scheduled_at)}</p>
                    {m.location && <p className="text-xs text-gray-400">{m.location}</p>}
                  </div>
                  <div className="flex flex-col items-end gap-1">
                    <Badge
                      label={isPast ? 'Completed' : 'Upcoming'}
                      className={isPast ? 'bg-gray-100 text-gray-500' : 'bg-blue-50 text-blue-700'}
                    />
                    {total > 0 && (
                      <span className="text-xs text-gray-500">{attended}/{total} attended</span>
                    )}
                  </div>
                </div>
              </Card>
            )
          })}
        </div>
      )}
    </div>
  )
}
