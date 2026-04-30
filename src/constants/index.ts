export const ROLES = {
  ADMIN:     'admin',
  DISCIPLER: 'discipler',
  DISCIPLE:  'disciple',
} as const

export const STATUS = {
  ACTIVE:   'active',
  INACTIVE: 'inactive',
} as const

export const PROGRESS = {
  NOT_STARTED: 'not_started',
  IN_PROGRESS: 'in_progress',
  COMPLETED:   'completed',
} as const

export const GENDER = {
  MALE:   'male',
  FEMALE: 'female',
  OTHER:  'other',
} as const

export const GROUP = {
  MAX_SIZE:        8,
  MIN_TRACK_WEEKS: 6,
  MAX_TRACK_WEEKS: 8,
} as const

export const ROLE_LABELS: Record<string, string> = {
  admin:     'Admin',
  discipler: 'Discipler',
  disciple:  'Disciple',
}

export const PROGRESS_LABELS: Record<string, string> = {
  not_started: 'Not Started',
  in_progress: 'In Progress',
  completed:   'Completed',
}

export const PROGRESS_COLORS: Record<string, string> = {
  not_started: 'bg-gray-100 text-gray-700',
  in_progress: 'bg-blue-100 text-blue-700',
  completed:   'bg-green-100 text-green-700',
}

export const STATUS_LABELS: Record<string, string> = {
  active:   'Active',
  inactive: 'Inactive',
}

export const GENDER_LABELS: Record<string, string> = {
  male:   'Male',
  female: 'Female',
  other:  'Other',
}

export const NAV_ITEMS = {
  admin: [
    { label: 'Dashboard', href: '/dashboard' },
    { label: 'Members',   href: '/members' },
    { label: 'Tracks',    href: '/tracks' },
    { label: 'Groups',    href: '/groups' },
    { label: 'Meetings',  href: '/meetings' },
    { label: 'Reports',   href: '/reports' },
  ],
  discipler: [
    { label: 'Dashboard', href: '/dashboard' },
    { label: 'My Group',  href: '/groups' },
    { label: 'Tracks',    href: '/tracks' },
    { label: 'Meetings',  href: '/meetings' },
  ],
  disciple: [
    { label: 'Dashboard',   href: '/dashboard' },
    { label: 'My Progress', href: '/tracks' },
    { label: 'My Group',    href: '/groups' },
    { label: 'Meetings',    href: '/meetings' },
  ],
} as const
