import { notFound } from 'next/navigation'
import { getMemberById } from '@/services/members'
import { getMemberProgress } from '@/services/progress'
import { getTracks } from '@/services/tracks'
import { Avatar } from '@/components/ui/Avatar'
import { Badge } from '@/components/ui/Badge'
import { Card, CardTitle } from '@/components/ui/Card'
import { ProgressBar } from '@/components/ProgressBar'
import { formatDate } from '@/utils/helpers'
import { ROLE_LABELS, GENDER_LABELS, PROGRESS_LABELS, PROGRESS_COLORS } from '@/constants'

export default async function MemberDetailPage({ params }: { params: { id: string } }) {
  const [member, progress, tracks] = await Promise.all([
    getMemberById(params.id).catch(() => null),
    getMemberProgress(params.id),
    getTracks(),
  ])

  if (!member) notFound()

  const progressByModule = Object.fromEntries(progress.map((p) => [p.module_id, p.status]))

  return (
    <div className="space-y-6">
      <Card>
        <div className="flex items-center gap-4">
          <Avatar name={member.name} size="lg" />
          <div className="flex-1">
            <h1 className="text-lg font-bold text-gray-900">{member.name}</h1>
            <p className="text-sm text-gray-500">{member.email}</p>
            {member.phone && <p className="text-sm text-gray-500">{member.phone}</p>}
          </div>
          <div className="flex flex-col gap-1 items-end">
            <Badge
              label={ROLE_LABELS[member.roles?.name ?? 'disciple']}
              className="bg-indigo-50 text-brand-primary"
            />
            {member.gender && (
              <Badge label={GENDER_LABELS[member.gender]} className="bg-gray-100 text-gray-600" />
            )}
          </div>
        </div>

        <dl className="mt-4 grid grid-cols-2 gap-3 text-sm">
          <div>
            <dt className="text-gray-500">Joined</dt>
            <dd className="font-medium text-gray-900">{formatDate(member.joined_at)}</dd>
          </div>
          {member.home_group && (
            <div>
              <dt className="text-gray-500">Home Group</dt>
              <dd className="font-medium text-gray-900">{member.home_group}</dd>
            </div>
          )}
        </dl>
      </Card>

      <Card>
        <CardTitle>Track Progress</CardTitle>
        <div className="mt-4 space-y-6">
          {tracks.map((track) => {
            const modules = track.modules ?? []
            const completed = modules.filter((m) => progressByModule[m.id] === 'completed').length
            const pct = modules.length ? Math.round((completed / modules.length) * 100) : 0

            return (
              <div key={track.id}>
                <div className="flex justify-between text-sm font-medium text-gray-900 mb-2">
                  <span>{track.title}</span>
                  <span>{completed}/{modules.length} modules</span>
                </div>
                <ProgressBar value={pct} />
                <div className="mt-2 space-y-1">
                  {modules.map((mod) => {
                    const status = progressByModule[mod.id] ?? 'not_started'
                    return (
                      <div key={mod.id} className="flex justify-between items-center text-xs py-1">
                        <span className="text-gray-700">{mod.title}</span>
                        <Badge
                          label={PROGRESS_LABELS[status]}
                          className={PROGRESS_COLORS[status]}
                        />
                      </div>
                    )
                  })}
                </div>
              </div>
            )
          })}
        </div>
      </Card>
    </div>
  )
}
