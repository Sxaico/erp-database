// web/src/pages/ProjectDetailsPage.tsx
import { useEffect, useMemo, useState } from "react";
import { useParams } from "react-router-dom";
import { apiFetch } from "../lib/api";

type Proyecto = {
  id: number; nombre: string; codigo?: string | null; estado: string; prioridad: number;
};
type Tarea = {
  id: number; uuid: string; proyecto_id: number; titulo: string; estado: string; prioridad: number; real_horas?: number | null;
};
type ResumenItem = { proyecto_id: number; proyecto: string; estado: string; cantidad: number };

export default function ProjectDetailsPage() {
  const { id } = useParams();
  const pid = Number(id);
  const [p, setP] = useState<Proyecto | null>(null);
  const [tareas, setTareas] = useState<Tarea[]>([]);
  const [resumen, setResumen] = useState<ResumenItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [err, setErr] = useState<string | null>(null);

  const [nueva, setNueva] = useState({ titulo: "", descripcion: "" });
  const [saving, setSaving] = useState(false);

  const agrupado = useMemo(() => {
    const map: Record<string, number> = {};
    resumen.forEach(r => { map[r.estado] = (map[r.estado] || 0) + r.cantidad; });
    return map;
  }, [resumen]);

  const load = async () => {
    setLoading(true); setErr(null);
    try {
      const [proy, ts, res] = await Promise.all([
        apiFetch<Proyecto>(`/api/projects/${pid}`),
        apiFetch<Tarea[]>(`/api/projects/${pid}/tasks`),
        apiFetch<ResumenItem[]>(`/api/projects/${pid}/report/estado`),
      ]);
      setP(proy); setTareas(ts); setResumen(res);
    } catch (e: any) {
      setErr(e.message || "Error al cargar");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { if (pid) load(); }, [pid]);

  const crearTarea = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!nueva.titulo.trim()) return;
    setSaving(true);
    try {
      await apiFetch<Tarea>("/api/projects/tasks", {
        method: "POST",
        json: { proyecto_id: pid, titulo: nueva.titulo, descripcion: nueva.descripcion || null, prioridad: 2 },
      });
      setNueva({ titulo: "", descripcion: "" });
      await load();
    } catch (e: any) {
      alert(e.message || "Error al crear tarea");
    } finally {
      setSaving(false);
    }
  };

  const cambiarEstado = async (t: Tarea, estado: string) => {
    try {
      await apiFetch<Tarea>(`/api/projects/tasks/${t.id}`, { method: "PATCH", json: { estado } });
      await load();
    } catch (e: any) {
      alert(e.message || "No se pudo cambiar estado");
    }
  };

  if (loading) return <div style={{ padding: 16 }}>Cargando...</div>;
  if (err) return <div style={{ padding: 16, color: "crimson" }}>{err}</div>;
  if (!p) return <div style={{ padding: 16 }}>Proyecto no encontrado</div>;

  return (
    <div style={{ maxWidth: 900, margin: "0 auto", padding: 16 }}>
      <h1>{p.nombre} {p.codigo ? <small style={{ color: "#666" }}>({p.codigo})</small> : null}</h1>
      <p>Estado: <b>{p.estado}</b> | Prioridad: {p.prioridad}</p>

      <section style={{ margin: "16px 0" }}>
        <h3>Reporte por estado</h3>
        {Object.keys(agrupado).length === 0 ? (
          <p>Sin datos</p>
        ) : (
          <ul>
            {Object.entries(agrupado).map(([k, v]) => (
              <li key={k}>{k}: {v}</li>
            ))}
          </ul>
        )}
      </section>

      <section style={{ margin: "16px 0" }}>
        <h3>Nueva tarea</h3>
        <form onSubmit={crearTarea} style={{ display: "grid", gap: 8, maxWidth: 500 }}>
          <input
            placeholder="Título *"
            required
            value={nueva.titulo}
            onChange={(e) => setNueva({ ...nueva, titulo: e.target.value })}
          />
          <input
            placeholder="Descripción (opcional)"
            value={nueva.descripcion}
            onChange={(e) => setNueva({ ...nueva, descripcion: e.target.value })}
          />
          <button type="submit" disabled={saving}>{saving ? "Creando..." : "Crear tarea"}</button>
        </form>
      </section>

      <section style={{ margin: "16px 0" }}>
        <h3>Tareas</h3>
        <table width="100%" cellPadding={8} style={{ borderCollapse: "collapse" }}>
          <thead>
            <tr>
              <th align="left">ID</th>
              <th align="left">Título</th>
              <th align="left">Estado</th>
              <th align="left">Acciones</th>
            </tr>
          </thead>
          <tbody>
            {tareas.map((t) => (
              <tr key={t.id} style={{ borderTop: "1px solid #eee" }}>
                <td>{t.id}</td>
                <td>{t.titulo}</td>
                <td>{t.estado}</td>
                <td style={{ display: "flex", gap: 8 }}>
                  <button onClick={() => cambiarEstado(t, "PENDIENTE")}>Pendiente</button>
                  <button onClick={() => cambiarEstado(t, "EN_PROGRESO")}>En progreso</button>
                  <button onClick={() => cambiarEstado(t, "HECHA")}>Hecha</button>
                </td>
              </tr>
            ))}
            {tareas.length === 0 && (
              <tr><td colSpan={4} style={{ textAlign: "center", padding: 24 }}>Sin tareas</td></tr>
            )}
          </tbody>
        </table>
      </section>
    </div>
  );
}
