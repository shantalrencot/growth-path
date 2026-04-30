import { createClient } from '@/utils/supabase/server'
import type { MemberProgress, UpdateProgressInput, GroupProgressSummary } from '@/types'

export async function getMemberProgress(memberId: string): Promise<MemberProgress[]> {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('member_progress')
    .select('*')
    .eq('member_id', memberId)
    .order('updated_at', { ascending: false })
  if (error) throw new Error(error.message)
  return data
}

export async function getMemberProgressByTrack(
  memberId: string,
  trackId: string
): Promise<MemberProgress[]> {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('member_progress')
    .select('*')
    .eq('member_id', memberId)
    .eq('track_id', trackId)
    .order('updated_at')
  if (error) throw new Error(error.message)
  return data
}

export async function upsertProgress(input: UpdateProgressInput): Promise<MemberProgress> {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('member_progress')
    .upsert({
      member_id: input.member_id,
      module_id: input.module_id,
      track_id:  input.track_id,
      status:    input.status,
    }, { onConflict: 'member_id,module_id' })
    .select()
    .single()
  if (error) throw new Error(error.message)
  return data
}

export async function getGroupProgressSummary(groupId: string): Promise<GroupProgressSummary[]> {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('group_progress_summary')
    .select('*')
    .eq('group_id', groupId)
  if (error) throw new Error(error.message)
  return data
}
