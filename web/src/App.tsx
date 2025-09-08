import { useEffect, useState } from "react";

const API_URL = import.meta.env.VITE_API_URL || "http://localhost:8000";

type Health = {
  status?: string;
  db?: string;
  version?: string;
};

export default function App() {
  const [health, setHealth] = useState<Health>({});
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    (async () => {
      try {
        setError(null);
        const res = await fetch(`${API_URL}/health`);
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        const data = await res.json();
        setHealth(data);
      } catch (e: any) {
        setError(e?.message || "Error al consultar health");
      }
    })();
  }, []);

  return (
    <div style={{ fontFamily: "system-ui, sans-serif", padding: 24, lineHeight: 1.4 }}>
      <h1>✅ ERP MVP UI en vivo</h1>
      <p>Si ves esto, React está montado y Vite sirve la app.</p>

      <h2 style={{ marginTop: 24 }}>Health de API</h2>
      {error ? (
        <p>⚠️ No se pudo obtener el health: {error}</p>
      ) : (
        <ul>
          <li><strong>Status:</strong> {health.status ?? "—"}</li>
          <li><strong>DB:</strong> {health.db ?? "—"}</li>
          <li><strong>Versión:</strong> {health.version ?? "—"}</li>
        </ul>
      )}
    </div>
  );
}
