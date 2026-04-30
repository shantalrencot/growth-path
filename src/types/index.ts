export type Role           = 'admin' | 'discipler' | 'disciple'
export type MemberStatus   = 'active' | 'inactive'
export type Gender         = 'male' | 'female' | 'other'
export type ProgressStatus = 'not_started' | 'in_progress' | 'completed'

export interface RoleRecord {
  id:          string
  name:        Role
  description: string | null
  created_at:  string
}

export interface Member {
  id:           string
  auth_id:      string | null
  name:         string
  email:        string
  phone:        string | null
  gender:       Gender | null
  home_group:   string | null
  role_id:      string
  is_discipler: boolean
  discipler_id: string | null
  status:       MemberStatus
  joined_at:    string
  created_at:   string
  updated_at:   string
  roles?:       RoleRecord
}

export interface Track {
  id:             string
  title:          string
  description:    string | null
  order_index:    number
  duration_weeks: number
  is_active:      boolean
  created_at:     string
  updated_at:     string
  modules?:       Module[]
}

export interface Module {
  id:          string
  track_id:    string
  title:       string
  description: string | null
  order_index: number
  is_active:   boolean
  created_at:  string
  updated_at:  string
}

// Minimal shapes returned by Supabase FK/join selects
export interface MemberSummary {
  id:     string
  name:   string
  email:  string
  phone?: string | null
  status?: MemberStatus
  gender?: Gender | null
}

export interface TrackSummary {
  id:          string
  title:       string
  order_index: number
  modules?:    Module[]
}

// group_members join returns { member: MemberSummary }[]
export interface GroupMemberEntry {
  member: MemberSummary
}

export interface DiscipleshipGroup {
  id:           string
  name:         string
  discipler_id: string
  track_id:     string
  max_size:     number
  is_active:    boolean
  created_at:   string
  updated_at:   string
  discipler?:   MemberSummary
  track?:       TrackSummary
  members?:     GroupMemberEntry[]
}

export interface GroupMember {
  id:        string
  group_id:  string
  member_id: string
  joined_at: string
}

export interface MemberProgress {
  id:           string
  member_id:    string
  module_id:    string
  track_id:     string
  status:       ProgressStatus
  completed_at: string | null
  updated_at:   string
}

export interface Meeting {
  id:           string
  group_id:     string
  title:        string | null
  scheduled_at: string
  location:     string | null
  notes:        string | null
  created_at:   string
  updated_at:   string
  attendance?:  Attendance[]
}

export interface Attendance {
  id:         string
  meeting_id: string
  member_id:  string
  attended:   boolean
  notes:      string | null
  created_at: string
  member?:    Member
}

// ── Input Types ───────────────────────────────────────────────

export interface CreateMemberInput {
  name:        string
  email:       string
  phone?:      string
  gender?:     Gender
  home_group?: string
  role_id:     string
}

export interface UpdateMemberInput {
  name?:         string
  phone?:        string
  gender?:       Gender
  home_group?:   string
  status?:       MemberStatus
  is_discipler?: boolean
  discipler_id?: string | null
  role_id?:      string
}

export interface CreateTrackInput {
  title:           string
  description?:    string
  order_index:     number
  duration_weeks?: number
}

export interface CreateModuleInput {
  track_id:     string
  title:        string
  description?: string
  order_index:  number
}

export interface CreateGroupInput {
  name:         string
  discipler_id: string
  track_id:     string
  max_size?:    number
}

export interface UpdateProgressInput {
  member_id: string
  module_id: string
  track_id:  string
  status:    ProgressStatus
}

export interface CreateMeetingInput {
  group_id:     string
  title?:       string
  scheduled_at: string
  location?:    string
  notes?:       string
}

export interface UpdateAttendanceInput {
  meeting_id: string
  member_id:  string
  attended:   boolean
  notes?:     string
}

// ── View / Aggregate Types ────────────────────────────────────

export interface GroupProgressSummary {
  group_id:              string
  group_name:            string
  member_id:             string
  member_name:           string
  track_title:           string
  total_modules:         number
  completed_modules:     number
  completion_percentage: number
}

export interface AttendanceSummary {
  group_id:        string
  group_name:      string
  meeting_id:      string
  scheduled_at:    string
  total_members:   number
  attended_count:  number
  attendance_rate: number
}

export interface DashboardStats {
  totalMembers:      number
  activeGroups:      number
  averageCompletion: number
  upcomingMeetings:  number
}
