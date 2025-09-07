import { useEffect, useState } from 'react'
import { getMyTasks, patchTask, addWorklog } from '../api'

type Task = { id: number; titulo: string; estado: string; prioridad: number; real_horas: number | null }

export default function MyTasks() {
  const [items, setItems] = useState<Task[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [hours, setHours] = useState<Record<number, string>>({})

  async function load() {
    try {
      const data = await getMyTasks()
      setItems(data)
    } catch (e: any) {
      setError(e.message)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => { load() }, [])

  const setEstado = async (id: number, estado: string) => {
    setError(null)
    try {
      const t = await patchTask(id, { estado })
      setItems(prev => prev.map(x => (x.id === id ? t : x)))
    } catch (e: any) {
      setError(e.message)
    }
  }

  const cargarHoras = async (id: number) => {
    setError(null)
    const h = parseFloat(hours[id] || '0')
    if (!h || h <= 0) return
    try {
      const t = await addWorklog(id, h)
      setItems(prev => prev.map(x => (x.id === id ? t : x)))
      setHours(prev => ({ ...prev, [id]: '' }))
    } catch (e: any) {
      setError(e.message)
    }
  }

  if (loading) return <div>Cargando...</div>

  return (
    <div style={{ display: 'grid', gap: 12 }}>
      <h2>Mis tareas</h2>
      {error && <div style={{ color: 'crimson' }}>{error}</div>}
      <ul style={{ display: 'grid', gap: 8 }}>
        {items.map(t => (
          <li key={t.id} style={{ border: '1px solid #ddd', padding: 8, borderRadius: 8 }}>
            <div><strong>{t.titulo}</strong></div>
            <div>Estado: {t.estado} · Prioridad: {t.prioridad} · Horas: {t.real_horas ?? 0}</div>
            <div style={{ display: 'flex', gap: 8, marginTop: 8 }}>
              <select value={t.estado} onChange={e => setEstado(t.id, e.target.value)}>
                <option value="PENDIENTE">PENDIENTE</option>
                <option value="EN_PROGRESO">EN_PROGRESO</option>
                <option value="HECHA">HECHA</option>
              </select>
              <input
                placeholder="Horas"
                value={hours[t.id] || ''}
                onChange={e => setHours(prev => ({ ...prev, [t.id]: e.target.value }))}
                style={{ width: 80 }}
              />
              <button onClick={() => cargarHoras(t.id)}>Cargar horas</button>
            </div>
          </li>
        ))}
      </ul>
    </div>
  )
}
