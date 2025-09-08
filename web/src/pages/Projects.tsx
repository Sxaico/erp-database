import React, { useEffect, useState } from "react";
import { apiFetch } from "../lib/api";

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

export default function Projects() {
  const [data, setData] = useState<Proyecto[] | null>(null);
  const [err, setErr] = useState<string | null>(null);

  useEffect(() => {
    (async () => {
      try {
        const items = await apiFetch<Proyecto[]>("/api/projects");
        setData(items);
      } catch (e: any) {
        setErr(e?.message || "No se pudo cargar proyectos");
      }
    })();
  }, []);

  return (
    <div style={{ padding: 24, fontFamily: "system-ui, sans-serif" }}>
      <h2>Proyectos</h2>
      {err && <div style={{ color: "#b00" }}>⚠️ {err}</div>}
      {!err && !data && <div>Cargando…</div>}
      {data && data.length === 0 && <div>No hay proyectos</div>}
      {data && data.length > 0 && (
        <div style={{ display: "grid", gap: 8 }}>
          {data.map((p) => (
            <div key={p.id} style={{ padding: 12, border: "1px solid #eee", borderRadius: 8 }}>
              <div style={{ fontWeight: 600 }}>{p.codigo || "(sin código)"} — {p.nombre}</div>
              <div style={{ fontSize: 13, color: "#555" }}>
                Estado: {p.estado} · Prioridad: {p.prioridad} · Avance: {p.avance_pct ?? 0}%
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
