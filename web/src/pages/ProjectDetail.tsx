// web/src/pages/ProjectDetail.tsx
import React, { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import { api } from "../api/client";

type Proyecto = { id:number; nombre:string; estado:string; codigo?:string; prioridad:number; };
type Tarea = { id:number; titulo:string; estado:string; prioridad:number; uuid:string; proyecto_id:number; };
type Member = { id:number; email:string; nombre?:string; apellido?:string; rol_en_proyecto:string; };
type SumItem = { proyecto_id:number; proyecto:string; estado:string; cantidad:number; };

const ESTADOS = ["PENDIENTE","EN_PROGRESO","BLOQUEADA","HECHA"];

export default function ProjectDetail() {
  const { id } = useParams();
  const pid = Number(id);
  const [proy, setProy] = useState<Proyecto | null>(null);
  const [tasks, setTasks] = useState<Tarea[]>([]);
  const [members, setMembers] = useState<Member[]>([]);
  const [resumen, setResumen] = useState<SumItem[]>([]);
  const [loading, setLoading] = useState(true);

  const load = async () => {
    setLoading(true);
    const [p, t, m, r] = await Promise.all([
      api.get<Proyecto>(`/api/projects/${pid}`),
      api.get<Tarea[]>(`/api/projects/${pid}/tasks`),
      api.get<Member[]>(`/api/projects/${pid}/members`).catch(()=>[]),
      api.get<SumItem[]>(`/api/projects/${pid}/report/estado`).catch(()=>[]),
    ]);
    setProy(p); setTasks(t); setMembers(m); setResumen(r);
    setLoading(false);
  };
  useEffect(()=>{ load(); }, [pid]);

  // crear tarea
  const [titulo, setTitulo] = useState("");
  const createTask = async (e: React.FormEvent) => {
    e.preventDefault();
    await api.post<Tarea>("/api/projects/tasks", { proyecto_id: pid, titulo, prioridad: 3 });
    setTitulo("");
    await load(); // ⟵ refresca
  };

  const changeEstado = async (taskId: number, estado: string) => {
    await api.patch<Tarea>(`/api/projects/tasks/${taskId}`, { estado });
    await load(); // ⟵ refresca después del cambio de estado
  };

  // agregar miembro por email (solo Admin en backend)
  const [email, setEmail] = useState("");
  const addMember = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await api.post<Member>(`/api/projects/${pid}/members`, { email });
      setEmail("");
      await load();
    } catch (e:any) {
      alert("No autorizado o email inexistente");
    }
  };

  if (loading) return <div style={{padding:16}}>Cargando…</div>;
  if (!proy) return <div style={{padding:16}}>Proyecto no encontrado</div>;

  return (
    <div style={{maxWidth:1000, margin:"24px auto", padding:"0 16px"}}>
      <h2>Proyecto #{proy.id} — {proy.nombre}</h2>
      <p style={{opacity:.7}}>Código: {proy.codigo || "-"} · Estado: {proy.estado}</p>

      <div style={{display:"grid", gap:20, gridTemplateColumns:"1fr"}}>
        {/* TAREAS */}
        <section style={{border:"1px solid #eee", borderRadius:12, padding:16}}>
          <h3 style={{marginTop:0}}>Tareas</h3>
          <form onSubmit={createTask} style={{display:"flex", gap:8, marginBottom:12}}>
            <input placeholder="Título de la tarea" value={titulo} onChange={e=>setTitulo(e.target.value)} required />
            <button type="submit">Agregar</button>
          </form>
          <table width="100%" cellPadding={8} style={{borderCollapse:"collapse"}}>
            <thead><tr style={{background:"#f7f7f7"}}><th align="left">ID</th><th align="left">Título</th><th>Estado</th></tr></thead>
            <tbody>
              {tasks.map(t=>(
                <tr key={t.id} style={{borderTop:"1px solid #eee"}}>
                  <td>{t.id}</td>
                  <td>{t.titulo}</td>
                  <td style={{textAlign:"center"}}>
                    <select value={t.estado} onChange={(e)=>changeEstado(t.id, e.target.value)}>
                      {ESTADOS.map(s=><option key={s} value={s}>{s}</option>)}
                    </select>
                  </td>
                </tr>
              ))}
              {!tasks.length && <tr><td colSpan={3} style={{padding:12, opacity:.7}}>Sin tareas</td></tr>}
            </tbody>
          </table>
        </section>

        {/* MIEMBROS */}
        <section style={{border:"1px solid #eee", borderRadius:12, padding:16}}>
          <h3 style={{marginTop:0}}>Miembros</h3>
          <form onSubmit={addMember} style={{display:"flex", gap:8, marginBottom:12}}>
            <input type="email" placeholder="email@miempresa.com" value={email} onChange={e=>setEmail(e.target.value)} />
            <button type="submit">Agregar</button>
          </form>
          <ul style={{margin:0, paddingLeft:20}}>
            {members.map(m=>(
              <li key={m.id}>{m.email} {m.nombre ? `— ${m.nombre} ${m.apellido}` : ""} <span style={{opacity:.6}}>({m.rol_en_proyecto})</span></li>
            ))}
            {!members.length && <li style={{opacity:.7}}>Sin miembros</li>}
          </ul>
        </section>

        {/* REPORTE */}
        <section style={{border:"1px solid #eee", borderRadius:12, padding:16}}>
          <h3 style={{marginTop:0}}>Reporte por estado</h3>
          {resumen.length ? (
            <table cellPadding={8}>
              <thead><tr><th align="left">Estado</th><th>Cantidad</th></tr></thead>
              <tbody>
                {resumen.map(r=>(
                  <tr key={r.estado}><td>{r.estado}</td><td style={{textAlign:"center"}}>{r.cantidad}</td></tr>
                ))}
              </tbody>
            </table>
          ) : <p style={{opacity:.7}}>Sin datos</p>}
        </section>
      </div>
    </div>
  );
}
