import { NextResponse } from 'next/server'
import { createMeeting, bulkUpsertAttendance } from '@/services/meetings'
import type { CreateMeetingInput } from '@/types'

export async function POST(req: Request) {
  try {
    const body: CreateMeetingInput = await req.json()
    const meeting = await createMeeting(body)
    return NextResponse.json(meeting, { status: 201 })
  } catch (err) {
    return NextResponse.json({ error: (err as Error).message }, { status: 400 })
  }
}

export async function PATCH(req: Request) {
  try {
    const { meeting_id, attendance } = await req.json()
    await bulkUpsertAttendance(meeting_id, attendance)
    return NextResponse.json({ success: true })
  } catch (err) {
    return NextResponse.json({ error: (err as Error).message }, { status: 400 })
  }
}
