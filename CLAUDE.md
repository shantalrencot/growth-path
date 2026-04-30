# The Disciples — Claude Code Master Guide

## What This App Is
A church discipleship tracking application. Every member goes through structured
tracks (each with modules) over 6-8 weeks, guided by a discipler in groups of max 8.

## Stack
- Frontend/Backend: Next.js 14 (App Router) + TypeScript
- Database: Supabase (PostgreSQL + Auth + RLS)
- Styling: Tailwind CSS (brand colors in tailwind.config.ts)
- Deployment: Vercel
- Version Control: GitHub

## Seeded Accounts (password: Disciples2024!)
- Admin:     shantalr@team.co.zw      (full access)
- Discipler: shantalrencot@gmail.com  (group access)
- Disciple:  rencoshantalt@gmail.com  (personal access)

---

## STRICT CODING RULES — FOLLOW FOR EVERY FILE

1.  No hardcoded values — all config in .env.local, never in source code
2.  All Supabase calls in /src/services/ only — never in components or pages
3.  Components only receive props and render UI — zero business logic inside
4.  All TypeScript types from /src/types/index.ts — no inline type definitions
5.  All status/role strings from /src/constants/index.ts — no raw strings in logic
6.  Role checks server-side via Supabase RLS — never trust the client for roles
7.  Every function under 30 lines — split if longer
8.  Every file under 200 lines — split into modules if longer
9.  Follow REST conventions for all API routes
10. Every DB table uses: id uuid, created_at, updated_at
11. Mobile-first UI — most users will be on phones
12. Handle loading AND error states on every data-fetching component
13. DRY — if logic appears twice, extract to a utility or hook
14. No commented-out code — delete it or don't write it

---

## User Roles & Access

| Role      | Can Read                     | Can Write                              |
|-----------|------------------------------|----------------------------------------|
| admin     | Everything                   | Everything + assign roles              |
| discipler | Own group members + progress | member_progress, meetings, attendance  |
| disciple  | Own profile + own progress   | Own profile fields, own module status  |

NEVER trust role from the client. Always verify via Supabase RLS.

---

## Folder Structure

src/
├── app/
│   ├── (auth)/
│   │   ├── login/page.tsx
│   │   └── register/page.tsx
│   └── (dashboard)/
│       ├── layout.tsx
│       ├── dashboard/page.tsx
│       ├── members/page.tsx + [id]/page.tsx
│       ├── tracks/page.tsx  + [id]/page.tsx
│       ├── groups/page.tsx  + [id]/page.tsx
│       ├── meetings/page.tsx
│       └── reports/page.tsx
├── components/ui/
├── services/        ← ALL Supabase calls live here
├── hooks/
├── constants/index.ts
├── types/index.ts
└── utils/
    ├── supabase/client.ts
    ├── supabase/server.ts
    └── helpers.ts

---

## API Route Pattern (REST)

GET    /api/members           → list members
POST   /api/members           → create member
GET    /api/members/:id       → get one member
PATCH  /api/members/:id       → update member
DELETE /api/members/:id       → soft delete (status = inactive)
GET    /api/tracks            → list tracks
POST   /api/tracks            → create track
GET    /api/groups            → list groups
POST   /api/groups            → create group
PATCH  /api/groups            → add/remove disciple
PATCH  /api/progress          → update module progress
POST   /api/meetings          → create meeting
PATCH  /api/meetings          → mark attendance

---

## Component Pattern

// CORRECT — dumb component, props only
interface MemberCardProps {
  name: string
  status: string
  progress: number
}
export const MemberCard = ({ name, status, progress }: MemberCardProps) => (
  <div>...</div>
)

// WRONG — never fetch inside a component
export const MemberCard = ({ memberId }: { memberId: string }) => {
  const [member, setMember] = useState(null)  // BAD
}

---

## Service Pattern

// src/services/members.ts
import { createClient } from '@/utils/supabase/server'
import { Member } from '@/types'

export async function getMembers(): Promise<Member[]> {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('members')
    .select('*, roles(name)')
    .eq('status', 'active')
    .order('name')
  if (error) throw new Error(error.message)
  return data
}

---

## UI Rules

- Brand primary: #3730A3 (indigo), accent: #D97706 (gold)
- Font: Inter via Tailwind sans
- Mobile-first: bottom nav on mobile, sidebar on desktop
- Icons: lucide-react only
- Loading states: skeleton loaders, not spinners
- Empty states: every list must have one
- Toast notifications: react-hot-toast for all actions
- No custom image uploads in v1 — initials avatars only
- All forms: single screen, no multi-step wizards

---

## Build Order

1.  Supabase schema.sql + rls_policies.sql     ✅
2.  Auth (login, register, session handling)   ✅
3.  Dashboard layout + navigation              ✅
4.  Members CRUD                               ✅ (list + detail)
5.  Tracks + modules management                ✅ (list + detail)
6.  Groups + discipler assignment              ✅ (list + detail)
7.  Progress tracking                          ✅
8.  Meetings + attendance                      ✅
9.  Reports + analytics                        ✅
10. Polish + mobile optimization               🔜
