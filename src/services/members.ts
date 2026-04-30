import { createClient } from '@/utils/supabase/server'
import type { Member, CreateMemberInput, UpdateMemberInput } from '@/types'

export async function getMembers(): Promise<Member[]> {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('members')
    .select('*, roles(id, name, description)')
    .eq('status', 'active')
    .order('name')
  if (error) throw new Error(error.message)
  return data
}

export async function getMemberById(id: string): Promise<Member> {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('members')
    .select('*, roles(id, name, description)')
    .eq('id', id)
    .single()
  if (error) throw new Error(error.message)
  return data
}

export async function getMemberByAuthId(authId: string): Promise<Member | null> {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('members')
    .select('*, roles(id, name, description)')
    .eq('auth_id', authId)
    .single()
  if (error) return null
  return data
}

export async function createMember(input: CreateMemberInput): Promise<Member> {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('members')
    .insert(input)
    .select('*, roles(id, name, description)')
    .single()
  if (error) throw new Error(error.message)
  return data
}

export async function updateMember(id: string, input: UpdateMemberInput): Promise<Member> {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('members')
    .update(input)
    .eq('id', id)
    .select('*, roles(id, name, description)')
    .single()
  if (error) throw new Error(error.message)
  return data
}

export async function deactivateMember(id: string): Promise<void> {
  const supabase = await createClient()
  const { error } = await supabase
    .from('members')
    .update({ status: 'inactive' })
    .eq('id', id)
  if (error) throw new Error(error.message)
}

export async function getRoles() {
  const supabase = await createClient()
  const { data, error } = await supabase.from('roles').select('*').order('name')
  if (error) throw new Error(error.message)
  return data
}
