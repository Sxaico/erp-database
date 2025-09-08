import React, { useEffect, useState } from "react";
import { useAuth } from "../auth/AuthContext";

const API = import.meta.env.VITE_API_URL ?? "http://localhost:8000";

export default function Home() {
  const { user, getAccessToken } = useAuth();
  const [health, setHealth] = useState<string>("...");
  const [err, setErr] = useState<string | null>(null);

  useEffect(() => {
    const run = async () => {
      try {
        const res = await fetch(`${API}/health`);
        if (!res.ok) throw new Error("No se pudo obtener health");
        const data = await res.json();
        setHealth(`API: ${data.status} / DB: ${data.database} / v${data.version}`);
      } catch (e: any) {
        setErr(e?.message || "Error al consultar health");
      }
    };
    void run();
  }, []);

  return (
    <div>
      <h2>✅ ERP MVP UI en vivo</h2>
      <p>Si ves esto, React está montado y Vite sirve la app.</p>
      <p><strong>Usuario:</strong> {user?.nombre_completo}</p>
      <h3>Health de API</h3>
      {err ? <p style={{ color: "#b91c1c" }}>⚠️ {err}</p> : <p>{health}</p>}
      <p style={{ opacity: .7, marginTop: 24 }}>Tip: navegá a “Proyectos” en el header.</p>
    </div>
  );
}
