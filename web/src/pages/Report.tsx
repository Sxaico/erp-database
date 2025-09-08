import React, { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import { useAuth } from "../auth/AuthContext";

type Resumen = {
  proyecto_id: number;
  proyecto: string;
  estado: string;
  cantidad: number;
};

const API = import.meta.env.VITE_API_URL ?? "http://localhost:8000";

export default function Report() {
  const { id } = useParams<{ id: string }>();
  const pid = Number(id);
  const { getAccessToken } = useAuth();
  const [items, setItems] = useState<Resumen[]>([]);
  const [err, setErr] = useState<string | null>(null);

  useEffect(() => {
    const run = async () => {
      setErr(null);
      try {
        const at = await getAccessToken();
        const res = await fetch(`${API}/api/projects/${pid}/report/estado`, {
          headers: { Authorization: `Bearer ${at}` }
        });
        if (!res.ok) throw new Error("No se pudo obtener el reporte");
        setItems(await res.json());
      } catch (e: any) {
        setErr(e?.message || "Error");
      }
    };
    void run();
  }, [pid, getAccessToken]);

  const total = items.reduce((acc, it) => acc + it.cantidad, 0);

  return (
    <div>
      <h2>Reporte por estado · Proyecto #{pid}</h2>
      {err && <p style={{ color: "#b91c1c" }}>⚠️ {err}</p>}
      {!err && (
        <>
          <ul>
            {items.map(x => (
              <li key={x.estado}>{x.estado}: <strong>{x.cantidad}</strong></li>
            ))}
          </ul>
          <p><strong>Total de tareas:</strong> {total}</p>
        </>
      )}
    </div>
  );
}
