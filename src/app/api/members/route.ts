import { NextResponse } from 'next/server'
import { getMembers, createMember } from '@/services/members'
import type { CreateMemberInput } from '@/types'

export async function GET() {
  try {
    const members = await getMembers()
    return NextResponse.json(members)
  } catch (err) {
    return NextResponse.json({ error: (err as Error).message }, { status: 500 })
  }
}

export async function POST(req: Request) {
  try {
    const body: CreateMemberInput = await req.json()
    const member = await createMember(body)
    return NextResponse.json(member, { status: 201 })
  } catch (err) {
    return NextResponse.json({ error: (err as Error).message }, { status: 400 })
  }
}
