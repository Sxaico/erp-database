// web/src/pages/Projects.tsx
import { useEffect, useState } from "react";
import { fetchProjects, createProject, type Project } from "../api";
import { Link } from "react-router-dom";

export default function ProjectsPage() {
  const [items, setItems] = useState<Project[]>([]);
  const [loading, setLoading] = useState(true);
  const [err, setErr] = useState<string|null>(null);
  const [nombre, setNombre] = useState("");
  const [codigo, setCodigo] = useState("");

  async function load() {
    setLoading(true); setErr(null);
    try { setItems(await fetchProjects()); }
    catch(e:any){ setErr(e?.message || "Error"); }
    finally{ setLoading(false); }
  }

  useEffect(() => { load(); }, []);

  async function onCreate(e: React.FormEvent) {
    e.preventDefault();
    const n = nombre.trim();
    if (!n) return;
    await createProject({ nombre: n, codigo: codigo.trim() || null, prioridad: 2 });
    setNombre(""); setCodigo("");
    // 🔁 REFRESH inmediato
    await load();
  }

  return (
    <div style={{maxWidth:800, margin:"24px auto", display:"grid", gap:16}}>
      <h2>Proyectos</h2>

      <form onSubmit={onCreate} style={{display:"grid", gridTemplateColumns:"1fr 200px 120px", gap:8}}>
        <input placeholder="Nombre del proyecto" value={nombre} onChange={e=>setNombre(e.target.value)} />
        <input placeholder="Código (opcional)" value={codigo} onChange={e=>setCodigo(e.target.value)} />
        <button type="submit">Crear</button>
      </form>

      {loading && <p>Cargando...</p>}
      {err && <p style={{color:"crimson"}}>{err}</p>}

      <ul style={{listStyle:"none", padding:0, margin:0, display:"grid", gap:6}}>
        {items.map(p => (
          <li key={p.id} style={{padding:12, border:"1px solid #eee", borderRadius:8}}>
            <div style={{display:"flex", justifyContent:"space-between", gap:12}}>
              <div>
                <strong>{p.nombre}</strong> {p.codigo ? `· ${p.codigo}` : ""}<br/>
                <small>Estado: {p.estado} · Prioridad: {p.prioridad}</small>
              </div>
              <Link to={`/projects/${p.id}`}>Abrir</Link>
            </div>
          </li>
        ))}
      </ul>
    </div>
  );
}
