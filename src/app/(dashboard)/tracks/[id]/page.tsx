import { notFound } from 'next/navigation'
import { getTrackById } from '@/services/tracks'
import { Card, CardTitle } from '@/components/ui/Card'
import { Badge } from '@/components/ui/Badge'

export default async function TrackDetailPage({ params }: { params: { id: string } }) {
  const track = await getTrackById(params.id).catch(() => null)
  if (!track) notFound()

  const modules = (track.modules ?? []).filter((m) => m.is_active).sort((a, b) => a.order_index - b.order_index)

  return (
    <div className="space-y-5">
      <div>
        <h1 className="text-xl font-bold text-gray-900">{track.title}</h1>
        {track.description && <p className="mt-1 text-sm text-gray-500">{track.description}</p>}
        <p className="mt-1 text-xs text-gray-400">{track.duration_weeks} weeks · {modules.length} modules</p>
      </div>

      <Card>
        <CardTitle>Modules</CardTitle>
        <ol className="mt-3 space-y-2">
          {modules.map((mod) => (
            <li key={mod.id} className="flex items-start gap-3 py-2 border-b border-gray-100 last:border-0">
              <span className="flex h-6 w-6 shrink-0 items-center justify-center rounded-full bg-indigo-50 text-xs font-semibold text-brand-primary">
                {mod.order_index}
              </span>
              <div className="flex-1">
                <p className="text-sm font-medium text-gray-900">{mod.title}</p>
                {mod.description && <p className="text-xs text-gray-500">{mod.description}</p>}
              </div>
              <Badge label="Active" className="bg-green-50 text-brand-success" />
            </li>
          ))}
        </ol>
      </Card>
    </div>
  )
}
