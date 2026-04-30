import Link from 'next/link'
import { BookOpen } from 'lucide-react'
import { getTracks } from '@/services/tracks'
import { Card } from '@/components/ui/Card'
import { Badge } from '@/components/ui/Badge'
import { EmptyState } from '@/components/ui/EmptyState'

export default async function TracksPage() {
  const tracks = await getTracks()

  return (
    <div className="space-y-4">
      <h1 className="text-xl font-bold text-gray-900">Tracks</h1>

      {tracks.length === 0 ? (
        <EmptyState icon={BookOpen} title="No tracks yet" description="Tracks will appear here once added." />
      ) : (
        <div className="space-y-3">
          {tracks.map((track) => (
            <Link key={track.id} href={`/tracks/${track.id}`}>
              <Card className="hover:border-brand-primary/30 transition-colors">
                <div className="flex items-center justify-between">
                  <div>
                    <h2 className="font-semibold text-gray-900">{track.title}</h2>
                    {track.description && (
                      <p className="mt-0.5 text-sm text-gray-500">{track.description}</p>
                    )}
                    <p className="mt-1 text-xs text-gray-400">{track.duration_weeks} weeks</p>
                  </div>
                  <div className="flex flex-col items-end gap-1">
                    <Badge label={`${track.modules?.length ?? 0} modules`} className="bg-indigo-50 text-brand-primary" />
                  </div>
                </div>
              </Card>
            </Link>
          ))}
        </div>
      )}
    </div>
  )
}
