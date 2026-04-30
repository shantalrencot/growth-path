import { NextResponse } from 'next/server'
import { upsertProgress } from '@/services/progress'
import type { UpdateProgressInput } from '@/types'

export async function PATCH(req: Request) {
  try {
    const body: UpdateProgressInput = await req.json()
    const progress = await upsertProgress(body)
    return NextResponse.json(progress)
  } catch (err) {
    return NextResponse.json({ error: (err as Error).message }, { status: 400 })
  }
}
