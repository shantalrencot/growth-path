import Link from 'next/link'
import { Users } from 'lucide-react'
import { getGroups } from '@/services/groups'
import { Card } from '@/components/ui/Card'
import { Badge } from '@/components/ui/Badge'
import { EmptyState } from '@/components/ui/EmptyState'

export default async function GroupsPage() {
  const groups = await getGroups()

  return (
    <div className="space-y-4">
      <h1 className="text-xl font-bold text-gray-900">Groups</h1>

      {groups.length === 0 ? (
        <EmptyState icon={Users} title="No groups yet" description="Groups will appear here once created." />
      ) : (
        <div className="space-y-3">
          {groups.map((group) => {
            const memberCount = group.members?.length ?? 0
            return (
              <Link key={group.id} href={`/groups/${group.id}`}>
                <Card className="hover:border-brand-primary/30 transition-colors">
                  <div className="flex items-center gap-3">
                    <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg bg-indigo-50">
                      <Users className="h-5 w-5 text-brand-primary" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <h2 className="font-semibold text-gray-900 truncate">{group.name}</h2>
                      <p className="text-xs text-gray-500 truncate">
                        Led by {group.discipler?.name ?? '—'}
                      </p>
                    </div>
                    <div className="flex flex-col items-end gap-1">
                      <Badge
                        label={`${memberCount}/${group.max_size} members`}
                        className={memberCount >= group.max_size ? 'bg-red-50 text-brand-danger' : 'bg-indigo-50 text-brand-primary'}
                      />
                      <span className="text-xs text-gray-400">{group.track?.title}</span>
                    </div>
                  </div>
                </Card>
              </Link>
            )
          })}
        </div>
      )}
    </div>
  )
}
