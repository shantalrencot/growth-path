import { NextResponse } from 'next/server'
import { getMemberById, updateMember, deactivateMember } from '@/services/members'
import type { UpdateMemberInput } from '@/types'

type Params = { params: { id: string } }

export async function GET(_: Request, { params }: Params) {
  try {
    const member = await getMemberById(params.id)
    return NextResponse.json(member)
  } catch (err) {
    return NextResponse.json({ error: (err as Error).message }, { status: 404 })
  }
}

export async function PATCH(req: Request, { params }: Params) {
  try {
    const body: UpdateMemberInput = await req.json()
    const member = await updateMember(params.id, body)
    return NextResponse.json(member)
  } catch (err) {
    return NextResponse.json({ error: (err as Error).message }, { status: 400 })
  }
}

export async function DELETE(_: Request, { params }: Params) {
  try {
    await deactivateMember(params.id)
    return NextResponse.json({ success: true })
  } catch (err) {
    return NextResponse.json({ error: (err as Error).message }, { status: 400 })
  }
}
