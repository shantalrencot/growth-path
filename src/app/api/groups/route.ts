import { NextResponse } from 'next/server'
import { getGroups, createGroup, addMemberToGroup, removeMemberFromGroup } from '@/services/groups'
import type { CreateGroupInput } from '@/types'

export async function GET() {
  try {
    const groups = await getGroups()
    return NextResponse.json(groups)
  } catch (err) {
    return NextResponse.json({ error: (err as Error).message }, { status: 500 })
  }
}

export async function POST(req: Request) {
  try {
    const body: CreateGroupInput = await req.json()
    const group = await createGroup(body)
    return NextResponse.json(group, { status: 201 })
  } catch (err) {
    return NextResponse.json({ error: (err as Error).message }, { status: 400 })
  }
}

export async function PATCH(req: Request) {
  try {
    const { group_id, member_id, action } = await req.json()
    if (action === 'add') {
      await addMemberToGroup(group_id, member_id)
    } else if (action === 'remove') {
      await removeMemberFromGroup(group_id, member_id)
    } else {
      return NextResponse.json({ error: 'Invalid action' }, { status: 400 })
    }
    return NextResponse.json({ success: true })
  } catch (err) {
    return NextResponse.json({ error: (err as Error).message }, { status: 400 })
  }
}
