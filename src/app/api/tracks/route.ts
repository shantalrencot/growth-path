import { NextResponse } from 'next/server'
import { getTracks, createTrack } from '@/services/tracks'
import type { CreateTrackInput } from '@/types'

export async function GET() {
  try {
    const tracks = await getTracks()
    return NextResponse.json(tracks)
  } catch (err) {
    return NextResponse.json({ error: (err as Error).message }, { status: 500 })
  }
}

export async function POST(req: Request) {
  try {
    const body: CreateTrackInput = await req.json()
    const track = await createTrack(body)
    return NextResponse.json(track, { status: 201 })
  } catch (err) {
    return NextResponse.json({ error: (err as Error).message }, { status: 400 })
  }
}
