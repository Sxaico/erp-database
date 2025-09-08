import React, { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import { useAuth } from "../auth/AuthContext";

type Tarea = {
  id: number;
  uuid: string;
  proyecto_id: number;
  titulo: string;
  estado: string;
  prioridad: number;
  real_horas?: number | null;
};

const API = import.meta.env.VITE_API_URL ?? "http://localhost:8000";

export default function ProjectDetail() {
  const { id } = useParams<{ id: string }>();
  const pid = Number(id);
  const { getAccessToken } = useAuth();
  const [items, setItems] = useState<Tarea[]>([]);
  const [err, setErr] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  const load = async () => {
    setErr(null);
    setLoading(true);
    try {
      const at = await getAccessToken();
      const res = await fetch(`${API}/api/projects/${pid}/tasks`, {
        headers: { Authorization: `Bearer ${at}` }
      });
      if (!res.ok) throw new Error("No se pudieron obtener tareas");
      setItems(await res.json());
    } catch (e: any) {
      setErr(e?.message || "Error");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { void load(); }, []);

  const updateEstado = async (taskId: number, estado: string) => {
    try {
      const at = await getAccessToken();
      const res = await fetch(`${API}/api/projects/tasks/${taskId}`, {
        method: "PATCH",
        headers: { "Content-Type": "application/json", Authorization: `Bearer ${at}` },
        body: JSON.stringify({ estado })
      });
      if (!res.ok) throw new Error("No se pudo actualizar tarea");
      await load();
    } catch (e: any) {
      alert(e?.message || "Error al actualizar");
    }
  };

  return (
    <div>
      <h2>Proyecto #{pid} · Tareas</h2>
      {loading && <p>Cargando...</p>}
      {err && <p style={{ color: "#b91c1c" }}>⚠️ {err}</p>}
      {!loading && !err && (
        <div style={{ overflowX: "auto" }}>
          <table style={{ width: "100%", borderCollapse: "collapse", background: "white", borderRadius: 12, overflow: "hidden" }}>
            <thead style={{ background: "#e2e8f0", textAlign: "left" }}>
              <tr>
                <th style={{ padding: 10 }}>#</th>
                <th style={{ padding: 10 }}>Título</th>
                <th style={{ padding: 10 }}>Estado</th>
                <th style={{ padding: 10 }}>Prioridad</th>
                <th style={{ padding: 10 }}>Acciones</th>
              </tr>
            </thead>
            <tbody>
              {items.map(t => (
                <tr key={t.id} style={{ borderBottom: "1px solid #e2e8f0" }}>
                  <td style={{ padding: 10 }}>{t.id}</td>
                  <td style={{ padding: 10 }}>{t.titulo}</td>
                  <td style={{ padding: 10 }}>{t.estado}</td>
                  <td style={{ padding: 10 }}>{t.prioridad}</td>
                  <td style={{ padding: 10 }}>
                    <select value={t.estado} onChange={(e)=>updateEstado(t.id, e.target.value)}>
                      <option value="PENDIENTE">PENDIENTE</option>
                      <option value="EN_PROGRESO">EN_PROGRESO</option>
                      <option value="HECHA">HECHA</option>
                    </select>
                  </td>
                </tr>
              ))}
              {items.length === 0 && (
                <tr><td colSpan={5} style={{ padding: 10, textAlign: "center" }}>Sin tareas.</td></tr>
              )}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
