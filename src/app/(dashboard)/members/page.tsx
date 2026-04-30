import Link from 'next/link'
import { Users, UserPlus } from 'lucide-react'
import { getMembers } from '@/services/members'
import { Card } from '@/components/ui/Card'
import { Avatar } from '@/components/ui/Avatar'
import { Badge } from '@/components/ui/Badge'
import { EmptyState } from '@/components/ui/EmptyState'
import { ROLE_LABELS, STATUS_LABELS } from '@/constants'

export default async function MembersPage() {
  const members = await getMembers()

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h1 className="text-xl font-bold text-gray-900">Members</h1>
        <Link
          href="/members/new"
          className="inline-flex items-center gap-1.5 rounded-lg bg-brand-primary px-3 py-2 text-sm font-medium text-white hover:bg-indigo-800"
        >
          <UserPlus className="h-4 w-4" />
          Add Member
        </Link>
      </div>

      {members.length === 0 ? (
        <EmptyState
          icon={Users}
          title="No members yet"
          description="Add your first member to get started."
        />
      ) : (
        <div className="space-y-2">
          {members.map((member) => (
            <Link key={member.id} href={`/members/${member.id}`}>
              <Card className="hover:border-brand-primary/30 transition-colors">
                <div className="flex items-center gap-3">
                  <Avatar name={member.name} />
                  <div className="flex-1 min-w-0">
                    <p className="font-medium text-gray-900 truncate">{member.name}</p>
                    <p className="text-xs text-gray-500 truncate">{member.email}</p>
                  </div>
                  <div className="flex flex-col items-end gap-1">
                    <Badge
                      label={ROLE_LABELS[member.roles?.name ?? 'disciple']}
                      className="bg-indigo-50 text-brand-primary"
                    />
                    <Badge
                      label={STATUS_LABELS[member.status]}
                      className={member.status === 'active' ? 'bg-green-50 text-brand-success' : 'bg-gray-100 text-gray-500'}
                    />
                  </div>
                </div>
              </Card>
            </Link>
          ))}
        </div>
      )}
    </div>
  )
}
