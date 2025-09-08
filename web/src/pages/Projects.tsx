import React, { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { useAuth } from "../auth/AuthContext";

type Proyecto = {
  id: number;
  uuid: string;
  codigo?: string | null;
  nombre: string;
  estado: string;
  prioridad: number;
  avance_pct?: number | null;
  presupuesto_monto?: number | null;
};

const API = import.meta.env.VITE_API_URL ?? "http://localhost:8000";

export default function Projects() {
  const { getAccessToken } = useAuth();
  const [items, setItems] = useState<Proyecto[]>([]);
  const [err, setErr] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const run = async () => {
      setLoading(true);
      setErr(null);
      try {
        const at = await getAccessToken();
        const res = await fetch(`${API}/api/projects`, {
          headers: { Authorization: `Bearer ${at}` }
        });
        if (!res.ok) throw new Error("No se pudieron obtener proyectos");
        const data: Proyecto[] = await res.json();
        setItems(data);
      } catch (e: any) {
        setErr(e?.message || "Error");
      } finally {
        setLoading(false);
      }
    };
    void run();
  }, [getAccessToken]);

  return (
    <div>
      <h2>Proyectos</h2>
      {loading && <p>Cargando...</p>}
      {err && <p style={{ color: "#b91c1c" }}>⚠️ {err}</p>}
      {!loading && !err && (
        <div style={{ overflowX: "auto" }}>
          <table style={{ width: "100%", borderCollapse: "collapse", background: "white", borderRadius: 12, overflow: "hidden" }}>
            <thead style={{ background: "#e2e8f0", textAlign: "left" }}>
              <tr>
                <th style={{ padding: 10 }}>#</th>
                <th style={{ padding: 10 }}>Código</th>
                <th style={{ padding: 10 }}>Nombre</th>
                <th style={{ padding: 10 }}>Estado</th>
                <th style={{ padding: 10 }}>Prioridad</th>
                <th style={{ padding: 10 }}>Acciones</th>
              </tr>
            </thead>
            <tbody>
              {items.map(p => (
                <tr key={p.id} style={{ borderBottom: "1px solid #e2e8f0" }}>
                  <td style={{ padding: 10 }}>{p.id}</td>
                  <td style={{ padding: 10 }}>{p.codigo || "-"}</td>
                  <td style={{ padding: 10 }}>{p.nombre}</td>
                  <td style={{ padding: 10 }}>{p.estado}</td>
                  <td style={{ padding: 10 }}>{p.prioridad}</td>
                  <td style={{ padding: 10 }}>
                    <Link to={`/projects/${p.id}`}>Ver tareas</Link>{" · "}
                    <Link to={`/projects/${p.id}/report`}>Reporte</Link>
                  </td>
                </tr>
              ))}
              {items.length === 0 && (
                <tr><td colSpan={6} style={{ padding: 10, textAlign: "center" }}>Sin proyectos visibles.</td></tr>
              )}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
