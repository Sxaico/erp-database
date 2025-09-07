// src/pages/Home.tsx
import React, { useEffect, useState } from 'react';
import { api } from '../api';

export default function Home() {
  const [msg, setMsg] = useState('Cargando...');
  const [extra, setExtra] = useState<string | null>(null);

  useEffect(() => {
    api.health()
      .then(h => {
        setMsg('✅ ERP MVP UI en vivo');
        setExtra(`Health de API → Status: ${h.status} | DB: ${h.db} | Versión: ${h.version}`);
      })
      .catch(() => {
        setMsg('⚠️ No se pudo consultar /health');
        setExtra(null);
      });
  }, []);

  return (
    <div style={{padding:16}}>
      <h2>{msg}</h2>
      <p>Si ves esto, React está montado y Vite sirve la app.</p>
      {extra && <pre style={{background:'#f6f8fa', padding:12, border:'1px solid #eee'}}>{extra}</pre>}
    </div>
  );
}
