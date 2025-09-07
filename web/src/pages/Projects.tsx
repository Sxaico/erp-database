// web/src/pages/Projects.tsx
import React, { useEffect, useState } from "react";
import { apiListProjects } from "../api";
import { Proyecto } from "../types";
import { Link } from "react-router-dom";
import { useAuth } from "../auth/AuthContext";

const wrap: React.CSSProperties = {
  maxWidth: 980,
  margin: "0 auto",
  padding: "24px 16px",
};

export default function Projects() {
  const { user, logout } = useAuth();
  const [items, setItems] = useState<Proyecto[]>([]);
  const [loading, setLoading] = useState(true);
  const [err, setErr] = useState<string | null>(null);

  useEffect(() => {
    let mounted = true;
    setLoading(true);
    apiListProjects()
      .then((data) => {
        if (mounted) setItems(data);
      })
      .catch((e) => setErr(e.message || "Error cargando proyectos"))
      .finally(() => setLoading(false));
    return () => {
      mounted = false;
    };
  }, []);

  return (
    <div style={wrap}>
      <header style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 16 }}>
        <div>
          <h2 style={{ margin: 0 }}>Proyectos</h2>
          <div style={{ fontSize: 13, opacity: 0.7 }}>Sesión: {user?.nombre_completo}</div>
        </div>
        <button onClick={logout} style={{ padding: "8px 10px", borderRadius: 8, border: "1px solid #cbd5e1", background: "white", cursor: "pointer" }}>
          Salir
        </button>
      </header>

      {loading && <div>Cargando...</div>}
      {err && <div style={{ color: "#b91c1c" }}>{err}</div>}

      {!loading && items.length === 0 && (
        <div style={{ padding: 16, border: "1px dashed #94a3b8", borderRadius: 12 }}>
          No hay proyectos aún. Creá uno con la API o usá los demo existentes.
        </div>
      )}

      <ul style={{ listStyle: "none", padding: 0, margin: 0, display: "grid", gap: 12 }}>
        {items.map((p) => (
          <li key={p.id} style={{ border: "1px solid #e2e8f0", borderRadius: 12, padding: 14, background: "white" }}>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
              <div>
                <div style={{ fontWeight: 600 }}>
                  <Link to={`/projects/${p.id}`}>{p.nombre}</Link>
                </div>
                <div style={{ fontSize: 13, opacity: 0.8 }}>
                  {p.codigo ? `${p.codigo} · ` : ""}{p.estado} · Prioridad {p.prioridad}
                </div>
              </div>
              <Link to={`/projects/${p.id}`} style={{ fontSize: 14 }}>Ver →</Link>
            </div>
          </li>
        ))}
      </ul>
    </div>
  );
}
