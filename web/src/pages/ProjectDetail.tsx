import { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import { getJSON, patchJSON } from "../api";

type Proyecto = {
  id: number; nombre: string; estado: string; codigo?: string | null;
};
type Tarea = {
  id: number; uuid: string; proyecto_id: number; titulo: string; estado: string; prioridad: number; real_horas?: number | null;
};
type Resumen = { proyecto_id: number; proyecto: string; estado: string; cantidad: number };

const ESTADOS = ["PENDIENTE", "EN_PROGRESO", "HECHA"];

export default function ProjectDetail() {
  const { id } = useParams<{ id: string }>();
  const pid = Number(id);

  const [proj, setProj] = useState<Proyecto | null>(null);
  const [tasks, setTasks] = useState<Tarea[]>([]);
  const [resumen, setResumen] = useState<Resumen[]>([]);

  async function load() {
    const p = await getJSON<Proyecto>(`/api/projects/${pid}`);
    setProj(p);
    const t = await getJSON<Tarea[]>(`/api/projects/${pid}/tasks`);
    setTasks(t);
    const r = await getJSON<Resumen[]>(`/api/projects/${pid}/report/estado`);
    setResumen(r);
  }

  useEffect(() => {
    load().catch(() => {});
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [pid]);

  async function updateEstado(taskId: number, estado: string) {
    await patchJSON<Tarea>(`/api/projects/tasks/${taskId}`, { estado });
    await load();
  }

  return (
    <div style={{ padding: 16 }}>
      {!proj ? (
        <div>Cargando...</div>
      ) : (
        <>
          <h3>{proj.codigo || `#${proj.id}`} — {proj.nombre}</h3>

          <div style={{ display: "flex", gap: 8, margin: "8px 0 16px" }}>
            {resumen.map(r => (
              <div key={r.estado} style={{ border: "1px solid #eee", borderRadius: 8, padding: "6px 10px" }}>
                <strong>{r.estado}</strong>: {r.cantidad}
              </div>
            ))}
            {resumen.length === 0 && <div style={{ color: "#888" }}>Sin datos de resumen.</div>}
          </div>

          <table style={{ width: "100%", borderCollapse: "collapse" }}>
            <thead>
              <tr style={{ textAlign: "left", borderBottom: "1px solid #eee" }}>
                <th style={{ padding: 8 }}>ID</th>
                <th style={{ padding: 8 }}>Título</th>
                <th style={{ padding: 8 }}>Estado</th>
                <th style={{ padding: 8 }}>Acción</th>
              </tr>
            </thead>
            <tbody>
              {tasks.map(t => (
                <tr key={t.id} style={{ borderBottom: "1px solid #f3f3f3" }}>
                  <td style={{ padding: 8 }}>{t.id}</td>
                  <td style={{ padding: 8 }}>{t.titulo}</td>
                  <td style={{ padding: 8 }}>{t.estado}</td>
                  <td style={{ padding: 8 }}>
                    <select value={t.estado} onChange={e => updateEstado(t.id, e.target.value)}>
                      {ESTADOS.map(s => <option key={s} value={s}>{s}</option>)}
                    </select>
                  </td>
                </tr>
              ))}
              {tasks.length === 0 && (
                <tr><td colSpan={4} style={{ padding: 8, color: "#888" }}>No hay tareas.</td></tr>
              )}
            </tbody>
          </table>
        </>
      )}
    </div>
  );
}
