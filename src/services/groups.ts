import { createClient } from '@/utils/supabase/server'
import type { DiscipleshipGroup, CreateGroupInput } from '@/types'

export async function getGroups(): Promise<DiscipleshipGroup[]> {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('discipleship_groups')
    .select(`
      *,
      discipler:members!discipler_id(id, name, email),
      track:tracks(id, title, order_index),
      members:group_members(member:members(id, name, email, status))
    `)
    .eq('is_active', true)
    .order('name')
  if (error) throw new Error(error.message)
  return data
}

export async function getGroupById(id: string): Promise<DiscipleshipGroup> {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('discipleship_groups')
    .select(`
      *,
      discipler:members!discipler_id(id, name, email, phone),
      track:tracks(*, modules(*)),
      members:group_members(member:members(id, name, email, phone, status, gender))
    `)
    .eq('id', id)
    .single()
  if (error) throw new Error(error.message)
  return data
}

export async function getGroupsByDiscipler(disciplerId: string): Promise<DiscipleshipGroup[]> {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('discipleship_groups')
    .select(`
      *,
      track:tracks(id, title, order_index),
      members:group_members(member:members(id, name, email, status))
    `)
    .eq('discipler_id', disciplerId)
    .eq('is_active', true)
    .order('name')
  if (error) throw new Error(error.message)
  return data
}

export async function createGroup(input: CreateGroupInput): Promise<DiscipleshipGroup> {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('discipleship_groups')
    .insert({ ...input, max_size: input.max_size ?? 8 })
    .select()
    .single()
  if (error) throw new Error(error.message)
  return data
}

export async function addMemberToGroup(groupId: string, memberId: string): Promise<void> {
  const supabase = await createClient()
  const { error } = await supabase
    .from('group_members')
    .insert({ group_id: groupId, member_id: memberId })
  if (error) throw new Error(error.message)
}

export async function removeMemberFromGroup(groupId: string, memberId: string): Promise<void> {
  const supabase = await createClient()
  const { error } = await supabase
    .from('group_members')
    .delete()
    .eq('group_id', groupId)
    .eq('member_id', memberId)
  if (error) throw new Error(error.message)
}

export async function updateGroup(id: string, input: Partial<CreateGroupInput>): Promise<DiscipleshipGroup> {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('discipleship_groups')
    .update(input)
    .eq('id', id)
    .select()
    .single()
  if (error) throw new Error(error.message)
  return data
}
