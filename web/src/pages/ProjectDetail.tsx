// web/src/pages/ProjectDetail.tsx
import React, { useEffect, useMemo, useState } from "react";
import { Link, useParams } from "react-router-dom";
import { apiCreateTask, apiGetProject, apiListTasks, apiResumenEstado, apiUpdateTask } from "../api";
import { Proyecto, ResumenEstadoItem, Tarea } from "../types";

const wrap: React.CSSProperties = {
  maxWidth: 980,
  margin: "0 auto",
  padding: "24px 16px",
};

const badge: React.CSSProperties = {
  display: "inline-block",
  padding: "4px 8px",
  borderRadius: 999,
  border: "1px solid #e2e8f0",
  background: "#f8fafc",
  fontSize: 12,
};

const formRow: React.CSSProperties = {
  display: "grid",
  gridTemplateColumns: "1fr auto auto",
  gap: 8,
};

export default function ProjectDetail() {
  const { id } = useParams();
  const pid = Number(id);
  const [project, setProject] = useState<Proyecto | null>(null);
  const [tasks, setTasks] = useState<Tarea[]>([]);
  const [report, setReport] = useState<ResumenEstadoItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [err, setErr] = useState<string | null>(null);

  const [newTitle, setNewTitle] = useState("");
  const [newPrio, setNewPrio] = useState(2);

  const counters = useMemo(() => {
    const m = new Map<string, number>();
    report.forEach(r => m.set(r.estado, r.cantidad));
    return {
      HECHA: m.get("HECHA") || 0,
      EN_PROGRESO: m.get("EN_PROGRESO") || 0,
      PENDIENTE: m.get("PENDIENTE") || 0,
    };
  }, [report]);

  useEffect(() => {
    let mounted = true;
    setLoading(true);
    Promise.all([
      apiGetProject(pid),
      apiListTasks(pid),
      apiResumenEstado(pid),
    ])
      .then(([p, ts, rep]) => {
        if (!mounted) return;
        setProject(p);
        setTasks(ts);
        setReport(rep);
      })
      .catch((e) => setErr(e.message || "Error cargando"))
      .finally(() => setLoading(false));
    return () => { mounted = false; };
  }, [pid]);

  async function createTask() {
    if (!newTitle.trim()) return;
    const t = await apiCreateTask({
      proyecto_id: pid,
      titulo: newTitle.trim(),
      prioridad: newPrio,
    });
    setTasks((prev) => [t, ...prev]);
    setNewTitle("");
    refreshReport();
  }

  async function setEstado(taskId: number, estado: Tarea["estado"]) {
    const updated = await apiUpdateTask(taskId, { estado });
    setTasks((prev) => prev.map(t => t.id === taskId ? updated : t));
    refreshReport();
  }

  async function refreshReport() {
    const rep = await apiResumenEstado(pid);
    setReport(rep);
  }

  return (
    <div style={wrap}>
      <div style={{ marginBottom: 16 }}>
        <Link to="/projects">← Volver</Link>
      </div>

      {loading && <div>Cargando...</div>}
      {err && <div style={{ color: "#b91c1c" }}>{err}</div>}

      {project && (
        <>
          <header style={{ display: "flex", justifyContent: "space-between", alignItems: "baseline", marginBottom: 8 }}>
            <h2 style={{ margin: 0 }}>{project.nombre}</h2>
            <div style={{ display: "flex", gap: 8 }}>
              <span style={badge}>Estado: {project.estado}</span>
              {project.codigo && <span style={badge}>Código: {project.codigo}</span>}
              <span style={badge}>Prioridad: {project.prioridad}</span>
            </div>
          </header>

          {/* Reporte por estado */}
          <div style={{ display: "flex", gap: 10, margin: "12px 0 20px" }}>
            <div style={{ ...badge, background: "#f0f9ff", borderColor: "#bae6fd" }}>HECHA: {counters.HECHA}</div>
            <div style={{ ...badge, background: "#fdf2f8", borderColor: "#fbcfe8" }}>EN PROGRESO: {counters.EN_PROGRESO}</div>
            <div style={{ ...badge, background: "#fefce8", borderColor: "#fde68a" }}>PENDIENTE: {counters.PENDIENTE}</div>
          </div>

          {/* Crear tarea */}
          <div style={{ border: "1px solid #e2e8f0", borderRadius: 12, padding: 12, background: "#fff", marginBottom: 16 }}>
            <div style={{ fontWeight: 600, marginBottom: 8 }}>Nueva tarea</div>
            <div style={formRow}>
              <input
                placeholder="Título de la tarea"
                value={newTitle}
                onChange={(e) => setNewTitle(e.target.value)}
                style={{ padding: "8px 10px", borderRadius: 8, border: "1px solid #cbd5e1" }}
              />
              <select
                value={newPrio}
                onChange={(e) => setNewPrio(parseInt(e.target.value))}
                style={{ padding: "8px 10px", borderRadius: 8, border: "1px solid #cbd5e1" }}
                title="Prioridad"
              >
                <option value={1}>Prioridad 1</option>
                <option value={2}>Prioridad 2</option>
                <option value={3}>Prioridad 3</option>
              </select>
              <button
                onClick={createTask}
                style={{ padding: "8px 10px", borderRadius: 8, border: "1px solid #334155", background: "#0f172a", color: "white", cursor: "pointer" }}
              >
                Crear
              </button>
            </div>
          </div>

          {/* Lista de tareas */}
          <div style={{ display: "grid", gap: 10 }}>
            {tasks.map((t) => (
              <div key={t.id} style={{ border: "1px solid #e2e8f0", borderRadius: 12, padding: 12, background: "#fff" }}>
                <div style={{ display: "flex", justifyContent: "space-between", gap: 8 }}>
                  <div>
                    <div style={{ fontWeight: 600 }}>{t.titulo}</div>
                    <div style={{ fontSize: 12, opacity: 0.8 }}>
                      Estado: {t.estado} · Prioridad {t.prioridad}
                    </div>
                  </div>
                  <div style={{ display: "flex", gap: 8 }}>
                    <button onClick={() => setEstado(t.id, "PENDIENTE")} style={btn("outline")}>Pendiente</button>
                    <button onClick={() => setEstado(t.id, "EN_PROGRESO")} style={btn("primary")}>En progreso</button>
                    <button onClick={() => setEstado(t.id, "HECHA")} style={btn("success")}>Hecha</button>
                  </div>
                </div>
              </div>
            ))}
            {tasks.length === 0 && (
              <div style={{ padding: 16, border: "1px dashed #94a3b8", borderRadius: 12, background: "#f8fafc" }}>
                Aún no hay tareas en este proyecto.
              </div>
            )}
          </div>
        </>
      )}
    </div>
  );
}

function btn(kind: "outline" | "primary" | "success"): React.CSSProperties {
  const base: React.CSSProperties = {
    padding: "8px 10px",
    borderRadius: 8,
    cursor: "pointer",
    border: "1px solid",
    background: "white",
  };
  if (kind === "outline") return { ...base, borderColor: "#cbd5e1" };
  if (kind === "primary") return { ...base, borderColor: "#334155", background: "#0f172a", color: "white" };
  return { ...base, borderColor: "#16a34a", background: "#dcfce7" };
}
