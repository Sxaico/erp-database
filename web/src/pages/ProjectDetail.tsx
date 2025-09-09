// web/src/pages/ProjectDetail.tsx
import { useEffect, useMemo, useState } from "react";
import { useParams, Link } from "react-router-dom";
import {
  fetchTasks,
  createTask,
  patchTask,
  fetchEstadoReport,
  type Task,
} from "../api";

// Estados sugeridos. Podés ajustar esta lista en un solo lugar.
const TASK_STATES = ["PENDIENTE", "EN_PROGRESO", "BLOQUEADA", "HECHA", "CANCELADA"] as const;

export default function ProjectDetailPage() {
  const { id } = useParams();
  const projectId = Number(id);
  const [tasks, setTasks] = useState<Task[]>([]);
  const [loading, setLoading] = useState(true);
  const [err, setErr] = useState<string | null>(null);
  const [titulo, setTitulo] = useState("");
  const [report, setReport] = useState<{ estado: string; cantidad: number }[]>([]);
  const [savingTaskId, setSavingTaskId] = useState<number | null>(null);

  async function reloadReport() {
    const r = await fetchEstadoReport(projectId);
    setReport(r.map((x) => ({ estado: x.estado, cantidad: x.cantidad })));
  }

  async function load() {
    setLoading(true);
    setErr(null);
    try {
      const [t, _] = await Promise.all([fetchTasks(projectId), reloadReport()]);
      setTasks(t);
    } catch (e: any) {
      setErr(e?.message || "Error");
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    load();
  }, [projectId]);

  async function onCreate(e: React.FormEvent) {
    e.preventDefault();
    const t = titulo.trim();
    if (!t) return;
    await createTask({ proyecto_id: projectId, titulo: t, prioridad: 2 });
    setTitulo("");
    await load(); // refresca tareas + reporte
  }

  async function changeEstado(taskId: number, nuevoEstado: string) {
    const prev = tasks.find((x) => x.id === taskId)?.estado;
    if (!prev || prev === nuevoEstado) return;

    setSavingTaskId(taskId);
    // Optimista: actualizamos UI al toque
    setTasks((curr) => curr.map((t) => (t.id === taskId ? { ...t, estado: nuevoEstado } : t)));

    try {
      await patchTask(taskId, { estado: nuevoEstado });
      await reloadReport();
    } catch (e) {
      // Revertir si falla
      setTasks((curr) => curr.map((t) => (t.id === taskId ? { ...t, estado: prev } : t)));
      alert("No se pudo actualizar el estado de la tarea.");
    } finally {
      setSavingTaskId(null);
    }
  }

  return (
    <div style={{ maxWidth: 900, margin: "24px auto", display: "grid", gap: 16 }}>
      <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
        <Link to="/projects">← Volver</Link>
        <h2 style={{ margin: 0 }}>Proyecto #{projectId}</h2>
      </div>

      <form onSubmit={onCreate} style={{ display: "grid", gridTemplateColumns: "1fr 140px", gap: 8 }}>
        <input
          placeholder="Nueva tarea..."
          value={titulo}
          onChange={(e) => setTitulo(e.target.value)}
        />
        <button type="submit">Crear tarea</button>
      </form>

      {loading && <p>Cargando...</p>}
      {err && <p style={{ color: "crimson" }}>{err}</p>}

      <section>
        <h3 style={{ marginBottom: 8 }}>Tareas</h3>
        <ul style={{ listStyle: "none", padding: 0, margin: 0, display: "grid", gap: 6 }}>
          {tasks.map((t) => {
            // Aseguramos que el estado actual esté siempre en el listado (por si viene algo distinto)
            const options = Array.from(new Set([t.estado, ...TASK_STATES]));
            return (
              <li
                key={t.id}
                style={{
                  padding: 12,
                  border: "1px solid #eee",
                  borderRadius: 8,
                  display: "flex",
                  justifyContent: "space-between",
                  alignItems: "center",
                  gap: 12,
                }}
              >
                <div>
                  <strong>{t.titulo}</strong>
                  <br />
                  <small>Prioridad: {t.prioridad}</small>
                </div>
                <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
                  <label>
                    <small>Estado:&nbsp;</small>
                    <select
                      value={t.estado}
                      disabled={savingTaskId === t.id}
                      onChange={(e) => changeEstado(t.id, e.target.value)}
                    >
                      {options.map((opt) => (
                        <option key={opt} value={opt}>
                          {opt}
                        </option>
                      ))}
                    </select>
                  </label>
                  {savingTaskId === t.id && <small style={{ opacity: 0.7 }}>Guardando…</small>}
                </div>
              </li>
            );
          })}
        </ul>
      </section>

      <section>
        <h3 style={{ marginBottom: 8 }}>Reporte por estado</h3>
        <div style={{ display: "flex", gap: 12, flexWrap: "wrap" }}>
          {report.map((r) => (
            <div key={r.estado} style={{ border: "1px solid #eee", borderRadius: 8, padding: "8px 12px" }}>
              <strong>{r.estado}</strong>: {r.cantidad}
            </div>
          ))}
          {!report.length && <small>No hay datos</small>}
        </div>
      </section>
    </div>
  );
}
