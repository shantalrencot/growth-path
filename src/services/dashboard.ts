import { createClient } from '@/utils/supabase/server'
import type { DashboardStats } from '@/types'

export async function getDashboardStats(): Promise<DashboardStats> {
  const supabase = await createClient()

  const [membersRes, groupsRes, progressRes, meetingsRes] = await Promise.all([
    supabase.from('members').select('id', { count: 'exact', head: true }).eq('status', 'active'),
    supabase.from('discipleship_groups').select('id', { count: 'exact', head: true }).eq('is_active', true),
    supabase.from('group_progress_summary').select('completion_percentage'),
    supabase
      .from('meetings')
      .select('id', { count: 'exact', head: true })
      .gte('scheduled_at', new Date().toISOString()),
  ])

  const totalMembers     = membersRes.count  ?? 0
  const activeGroups     = groupsRes.count   ?? 0
  const upcomingMeetings = meetingsRes.count ?? 0

  const rows = progressRes.data ?? []
  const averageCompletion = rows.length
    ? Math.round(rows.reduce((sum, r) => sum + Number(r.completion_percentage ?? 0), 0) / rows.length)
    : 0

  return { totalMembers, activeGroups, averageCompletion, upcomingMeetings }
}
