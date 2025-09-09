// web/src/pages/Projects.tsx
import { useEffect, useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { createProject, fetchProjects, logout, type Project } from "../api";

export default function ProjectsPage() {
  const [items, setItems] = useState<Project[]>([]);
  const [loading, setLoading] = useState(true);
  const [err, setErr] = useState<string | null>(null);
  const [codigo, setCodigo] = useState("");
  const [nombre, setNombre] = useState("");
  const [creating, setCreating] = useState(false);
  const nav = useNavigate();

  async function load() {
    setLoading(true); setErr(null);
    try {
      const data = await fetchProjects();
      setItems(data);
    } catch (e: any) {
      setErr(e?.message || "Error");
    } finally {
      setLoading(false);
    }
  }
  useEffect(()=>{ load(); }, []);

  async function onCreate(e: React.FormEvent) {
    e.preventDefault();
    if (!nombre.trim()) return;
    setCreating(true);
    try {
      const p = await createProject({ codigo: codigo || undefined, nombre: nombre.trim(), prioridad: 2 });
      setCodigo(""); setNombre("");
      await load();                // ← refresca lista
      nav(`/projects/${p.id}`);    // opcional: ir al detalle del recién creado
    } catch (e:any) {
      alert(e?.message || "No se pudo crear el proyecto");
    } finally {
      setCreating(false);
    }
  }

  return (
    <div style={{ maxWidth: 900, margin: "24px auto", display: "grid", gap: 16 }}>
      <header style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
        <h2 style={{ margin: 0 }}>Proyectos</h2>
        <button onClick={()=>{ logout(); nav("/login", { replace: true }); }}>Salir</button>
      </header>

      <form onSubmit={onCreate} style={{ display: "grid", gridTemplateColumns: "160px 1fr 120px", gap: 8 }}>
        <input placeholder="Código (opcional)" value={codigo} onChange={(e)=>setCodigo(e.target.value)} />
        <input placeholder="Nombre del proyecto" value={nombre} onChange={(e)=>setNombre(e.target.value)} />
        <button disabled={creating} type="submit">{creating? "Creando…" : "Crear"}</button>
      </form>

      {loading && <p>Cargando…</p>}
      {err && <p style={{ color: "crimson" }}>{err}</p>}

      <ul style={{ listStyle: "none", padding: 0, margin: 0, display: "grid", gap: 8 }}>
        {items.map(p => (
          <li key={p.id} style={{ border: "1px solid #eee", borderRadius: 8, padding: 12, display: "flex", justifyContent: "space-between" }}>
            <div>
              <strong>{p.codigo ? `${p.codigo} — ` : ""}{p.nombre}</strong><br/>
              <small>Estado: {p.estado} · Prioridad: {p.prioridad}</small>
            </div>
            <Link to={`/projects/${p.id}`}>Ver</Link>
          </li>
        ))}
      </ul>

      {!loading && !items.length && <small>No hay proyectos todavía.</small>}
    </div>
  );
}
