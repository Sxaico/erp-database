// web/src/pages/Projects.tsx
import React, { useEffect, useState } from "react";
import { api } from "../api/client";
import { Link } from "react-router-dom";

type Proyecto = { id:number; codigo?:string; nombre:string; estado:string; prioridad:number; };

export default function Projects() {
  const [items, setItems] = useState<Proyecto[]>([]);
  const [loading, setLoading] = useState(true);
  const [err, setErr] = useState<string | null>(null);
  const [nombre, setNombre] = useState("");
  const [codigo, setCodigo] = useState("");

  const load = async () => {
    setLoading(true); setErr(null);
    try {
      const data = await api.get<Proyecto[]>("/api/projects");
      setItems(data);
    } catch (e:any) {
      setErr(e.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { load(); }, []);

  const create = async (e: React.FormEvent) => {
    e.preventDefault();
    await api.post<Proyecto>("/api/projects", { nombre, codigo: codigo || undefined, prioridad: 3 });
    setNombre(""); setCodigo("");
    await load(); // ⟵ refresca después de crear
  };

  return (
    <div style={{maxWidth:900, margin:"24px auto", padding:"0 16px"}}>
      <h2>Proyectos</h2>

      <form onSubmit={create} style={{display:"flex", gap:8, margin:"12px 0 20px"}}>
        <input placeholder="Código (opcional)" value={codigo} onChange={e=>setCodigo(e.target.value)} />
        <input placeholder="Nombre" value={nombre} onChange={e=>setNombre(e.target.value)} required />
        <button type="submit">Crear</button>
      </form>

      {loading && <p>Cargando…</p>}
      {err && <p style={{color:"tomato"}}>{err}</p>}

      {!loading && !err && (
        <table width="100%" cellPadding={8} style={{borderCollapse:"collapse"}}>
          <thead>
            <tr style={{background:"#f7f7f7"}}>
              <th align="left">ID</th><th align="left">Código</th><th align="left">Nombre</th><th>Estado</th><th></th>
            </tr>
          </thead>
          <tbody>
            {items.map(p=>(
              <tr key={p.id} style={{borderTop:"1px solid #eee"}}>
                <td>{p.id}</td>
                <td>{p.codigo || "-"}</td>
                <td>{p.nombre}</td>
                <td style={{textAlign:"center"}}>{p.estado}</td>
                <td style={{textAlign:"right"}}>
                  <Link to={`/projects/${p.id}`}>Abrir</Link>
                </td>
              </tr>
            ))}
            {!items.length && <tr><td colSpan={5} style={{padding:16, opacity:.7}}>Sin proyectos</td></tr>}
          </tbody>
        </table>
      )}
    </div>
  );
}
