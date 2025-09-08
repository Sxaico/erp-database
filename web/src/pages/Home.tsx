import React, { useEffect, useState } from "react";

type Health = {
  status: string;
  database: string;
  version: string;
  timestamp: string;
};

export default function Home() {
  const [health, setHealth] = useState<Health | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    (async () => {
      try {
        const res = await fetch(import.meta.env.VITE_API_URL + "/health");
        if (!res.ok) throw new Error("HTTP " + res.status);
        const data = (await res.json()) as Health;
        setHealth(data);
      } catch (e: any) {
        setError(e?.message || "No se pudo obtener el health");
      }
    })();
  }, []);

  return (
    <div style={{ padding: 24, fontFamily: "system-ui, sans-serif" }}>
      <h1>✅ ERP MVP UI en vivo</h1>
      <p>Si ves esto, React está montado y Vite sirve la app.</p>

      <h3>Health de API</h3>
      {health && (
        <pre
          style={{
            background: "#f6f6f6",
            padding: 12,
            borderRadius: 8,
            overflowX: "auto",
          }}
        >
          {JSON.stringify(health, null, 2)}
        </pre>
      )}
      {!health && error && (
        <div style={{ color: "#b00" }}>
          ⚠️ No se pudo obtener el health: {error}
        </div>
      )}
    </div>
  );
}
