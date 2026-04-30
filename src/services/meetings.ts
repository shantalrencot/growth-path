import { createClient } from '@/utils/supabase/server'
import type { Meeting, CreateMeetingInput, UpdateAttendanceInput } from '@/types'

export async function getMeetingsByGroup(groupId: string): Promise<Meeting[]> {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('meetings')
    .select('*, attendance(*, member:members(id, name))')
    .eq('group_id', groupId)
    .order('scheduled_at', { ascending: false })
  if (error) throw new Error(error.message)
  return data
}

export async function getMeetingById(id: string): Promise<Meeting> {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('meetings')
    .select('*, attendance(*, member:members(id, name, email))')
    .eq('id', id)
    .single()
  if (error) throw new Error(error.message)
  return data
}

export async function getUpcomingMeetings(limit = 5): Promise<Meeting[]> {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('meetings')
    .select('*, discipleship_groups(id, name)')
    .gte('scheduled_at', new Date().toISOString())
    .order('scheduled_at')
    .limit(limit)
  if (error) throw new Error(error.message)
  return data
}

export async function createMeeting(input: CreateMeetingInput): Promise<Meeting> {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('meetings')
    .insert(input)
    .select()
    .single()
  if (error) throw new Error(error.message)
  return data
}

export async function updateMeeting(id: string, input: Partial<CreateMeetingInput>): Promise<Meeting> {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('meetings')
    .update(input)
    .eq('id', id)
    .select()
    .single()
  if (error) throw new Error(error.message)
  return data
}

export async function upsertAttendance(input: UpdateAttendanceInput): Promise<void> {
  const supabase = await createClient()
  const { error } = await supabase
    .from('attendance')
    .upsert({
      meeting_id: input.meeting_id,
      member_id:  input.member_id,
      attended:   input.attended,
      notes:      input.notes ?? null,
    }, { onConflict: 'meeting_id,member_id' })
  if (error) throw new Error(error.message)
}

export async function bulkUpsertAttendance(
  meetingId: string,
  records: { member_id: string; attended: boolean }[]
): Promise<void> {
  const supabase = await createClient()
  const rows = records.map((r) => ({
    meeting_id: meetingId,
    member_id:  r.member_id,
    attended:   r.attended,
  }))
  const { error } = await supabase
    .from('attendance')
    .upsert(rows, { onConflict: 'meeting_id,member_id' })
  if (error) throw new Error(error.message)
}
