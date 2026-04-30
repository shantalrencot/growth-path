import { BarChart2 } from 'lucide-react'
import { createClient } from '@/utils/supabase/server'
import { getGroups } from '@/services/groups'
import { getGroupProgressSummary } from '@/services/progress'
import { Card, CardTitle } from '@/components/ui/Card'
import { ProgressBar } from '@/components/ProgressBar'
import { EmptyState } from '@/components/ui/EmptyState'

export default async function ReportsPage() {
  const groups = await getGroups()

  const groupProgress = await Promise.all(
    groups.map(async (g) => ({
      group: g,
      rows:  await getGroupProgressSummary(g.id),
    }))
  )

  const hasData = groupProgress.some((gp) => gp.rows.length > 0)

  return (
    <div className="space-y-5">
      <h1 className="text-xl font-bold text-gray-900">Reports</h1>

      {!hasData ? (
        <EmptyState
          icon={BarChart2}
          title="No data yet"
          description="Progress reports will appear once members start completing modules."
        />
      ) : (
        groupProgress
          .filter((gp) => gp.rows.length > 0)
          .map(({ group, rows }) => {
            const avg = Math.round(
              rows.reduce((sum, r) => sum + Number(r.completion_percentage ?? 0), 0) / rows.length
            )
            return (
              <Card key={group.id}>
                <div className="flex justify-between items-center mb-3">
                  <CardTitle>{group.name}</CardTitle>
                  <span className="text-sm font-semibold text-brand-primary">{avg}% avg</span>
                </div>
                <div className="space-y-3">
                  {rows.map((r) => (
                    <div key={r.member_id}>
                      <div className="flex justify-between text-xs text-gray-600 mb-1">
                        <span>{r.member_name}</span>
                        <span>{r.completed_modules}/{r.total_modules} modules</span>
                      </div>
                      <ProgressBar value={Number(r.completion_percentage)} size="sm" showLabel={false} />
                    </div>
                  ))}
                </div>
              </Card>
            )
          })
      )}
    </div>
  )
}
