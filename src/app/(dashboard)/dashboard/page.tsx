import { Users, BookOpen, TrendingUp, Calendar } from 'lucide-react'
import { getDashboardStats } from '@/services/dashboard'
import { getUpcomingMeetings } from '@/services/meetings'
import { StatsCard } from '@/components/ui/StatsCard'
import { Card } from '@/components/ui/Card'
import { formatDateTime } from '@/utils/helpers'

export default async function DashboardPage() {
  const [stats, meetings] = await Promise.all([
    getDashboardStats(),
    getUpcomingMeetings(3),
  ])

  return (
    <div className="space-y-6">
      <h1 className="text-xl font-bold text-gray-900">Dashboard</h1>

      <div className="grid grid-cols-2 gap-3 sm:grid-cols-4">
        <StatsCard label="Total Members"      value={stats.totalMembers}      icon={Users}     color="indigo" />
        <StatsCard label="Active Groups"      value={stats.activeGroups}      icon={BookOpen}  color="amber"  />
        <StatsCard label="Avg Completion"     value={`${stats.averageCompletion}%`} icon={TrendingUp} color="green" />
        <StatsCard label="Upcoming Meetings"  value={stats.upcomingMeetings}  icon={Calendar}  color="red"    />
      </div>

      <Card>
        <h2 className="mb-4 text-sm font-semibold text-gray-900">Upcoming Meetings</h2>
        {meetings.length === 0 ? (
          <p className="text-sm text-gray-500">No upcoming meetings scheduled.</p>
        ) : (
          <ul className="divide-y divide-gray-100">
            {meetings.map((m) => (
              <li key={m.id} className="py-3 flex justify-between items-center">
                <div>
                  <p className="text-sm font-medium text-gray-900">{m.title ?? 'Group Meeting'}</p>
                  <p className="text-xs text-gray-500">{m.location ?? 'Location TBD'}</p>
                </div>
                <span className="text-xs text-gray-500">{formatDateTime(m.scheduled_at)}</span>
              </li>
            ))}
          </ul>
        )}
      </Card>
    </div>
  )
}
