import { createClient } from '@/utils/supabase/server'
import type { Track, Module, CreateTrackInput, CreateModuleInput } from '@/types'

export async function getTracks(): Promise<Track[]> {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('tracks')
    .select('*, modules(id, title, order_index, is_active)')
    .eq('is_active', true)
    .order('order_index')
  if (error) throw new Error(error.message)
  return data
}

export async function getTrackById(id: string): Promise<Track> {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('tracks')
    .select('*, modules(*)')
    .eq('id', id)
    .order('order_index', { referencedTable: 'modules' })
    .single()
  if (error) throw new Error(error.message)
  return data
}

export async function createTrack(input: CreateTrackInput): Promise<Track> {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('tracks')
    .insert(input)
    .select()
    .single()
  if (error) throw new Error(error.message)
  return data
}

export async function updateTrack(id: string, input: Partial<CreateTrackInput>): Promise<Track> {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('tracks')
    .update(input)
    .eq('id', id)
    .select()
    .single()
  if (error) throw new Error(error.message)
  return data
}

export async function getModulesByTrack(trackId: string): Promise<Module[]> {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('modules')
    .select('*')
    .eq('track_id', trackId)
    .eq('is_active', true)
    .order('order_index')
  if (error) throw new Error(error.message)
  return data
}

export async function createModule(input: CreateModuleInput): Promise<Module> {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('modules')
    .insert(input)
    .select()
    .single()
  if (error) throw new Error(error.message)
  return data
}
