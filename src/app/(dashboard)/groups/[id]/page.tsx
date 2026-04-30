import { notFound } from 'next/navigation'
import { getGroupById } from '@/services/groups'
import { getGroupProgressSummary } from '@/services/progress'
import { getMeetingsByGroup } from '@/services/meetings'
import { Card, CardTitle } from '@/components/ui/Card'
import { Avatar } from '@/components/ui/Avatar'
import { ProgressBar } from '@/components/ProgressBar'
import { Badge } from '@/components/ui/Badge'
import { formatDateTime } from '@/utils/helpers'

export default async function GroupDetailPage({ params }: { params: { id: string } }) {
  const group = await getGroupById(params.id).catch(() => null)
  if (!group) notFound()

  const [progressRows, meetings] = await Promise.all([
    getGroupProgressSummary(params.id),
    getMeetingsByGroup(params.id),
  ])

  const groupMembers = group.members ?? []
  const recentMeetings = meetings.slice(0, 3)

  return (
    <div className="space-y-5">
      <div>
        <h1 className="text-xl font-bold text-gray-900">{group.name}</h1>
        <p className="text-sm text-gray-500">
          Led by {group.discipler?.name} · {group.track?.title}
        </p>
      </div>

      <Card>
        <CardTitle>Members ({groupMembers.length}/{group.max_size})</CardTitle>
        <ul className="mt-3 divide-y divide-gray-100">
          {groupMembers.map(({ member }) => {
            const memberProgress = progressRows.find((p) => p.member_id === member.id)
            return (
              <li key={member.id} className="flex items-center gap-3 py-3">
                <Avatar name={member.name} size="sm" />
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium text-gray-900 truncate">{member.name}</p>
                  {memberProgress && (
                    <ProgressBar
                      value={Number(memberProgress.completion_percentage)}
                      size="sm"
                      showLabel={false}
                    />
                  )}
                </div>
                {memberProgress && (
                  <span className="text-xs font-medium text-gray-600">
                    {memberProgress.completion_percentage}%
                  </span>
                )}
              </li>
            )
          })}
        </ul>
      </Card>

      <Card>
        <CardTitle>Recent Meetings</CardTitle>
        {recentMeetings.length === 0 ? (
          <p className="mt-2 text-sm text-gray-500">No meetings yet.</p>
        ) : (
          <ul className="mt-3 divide-y divide-gray-100">
            {recentMeetings.map((m) => {
              const total    = m.attendance?.length ?? 0
              const attended = m.attendance?.filter((a) => a.attended).length ?? 0
              return (
                <li key={m.id} className="flex justify-between items-center py-3">
                  <div>
                    <p className="text-sm font-medium text-gray-900">{m.title ?? 'Group Meeting'}</p>
                    <p className="text-xs text-gray-500">{formatDateTime(m.scheduled_at)}</p>
                  </div>
                  {total > 0 && (
                    <Badge
                      label={`${attended}/${total} attended`}
                      className="bg-indigo-50 text-brand-primary"
                    />
                  )}
                </li>
              )
            })}
          </ul>
        )}
      </Card>
    </div>
  )
}
