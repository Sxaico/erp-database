// src/pages/Projects.tsx
import React, { useEffect, useState } from 'react';
import { api, Project } from '../api';
import { useAuth } from '../auth/AuthContext';
import { hasRole } from '../authHelpers';

export default function Projects() {
  const { user } = useAuth();
  const [items, setItems] = useState<Project[]>([]);
  const [loading, setLoading] = useState(true);
  const [err, setErr] = useState<string | null>(null);
  const [creating, setCreating] = useState(false);
  const [nombre, setNombre] = useState('');
  const [descripcion, setDescripcion] = useState('');

  async function load() {
    setLoading(true);
    setErr(null);
    try {
      const list = await api.projects.list();
      setItems(list);
    } catch (e: any) {
      setErr(e?.message || 'Error cargando proyectos');
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => { load(); }, []);

  async function onCreate(e: React.FormEvent) {
    e.preventDefault();
    setCreating(true);
    setErr(null);
    try {
      await api.projects.create({ nombre, descripcion });
      setNombre(''); setDescripcion('');
      await load();
      alert('Proyecto creado');
    } catch (e: any) {
      setErr(e?.message || 'Error creando proyecto');
    } finally {
      setCreating(false);
    }
  }

  const canCreate = hasRole(user, 'Super Admin');

  return (
    <div style={{padding:16}}>
      <h2>Projects</h2>

      {canCreate && (
        <details style={{margin:'12px 0'}}>
          <summary><strong>Nuevo proyecto</strong></summary>
          <form onSubmit={onCreate} style={{display:'grid', gap:8, marginTop:8}}>
            <label>Nombre
              <input value={nombre} onChange={e=>setNombre(e.target.value)} required />
            </label>
            <label>Descripción
              <input value={descripcion} onChange={e=>setDescripcion(e.target.value)} />
            </label>
            <button type="submit" disabled={creating}>
              {creating ? 'Creando...' : 'Crear'}
            </button>
          </form>
        </details>
      )}

      {loading ? <p>Cargando...</p> :
        err ? <p style={{color:'crimson'}}>{err}</p> :
        items.length === 0 ? <p>Sin proyectos.</p> : (
          <table style={{borderCollapse:'collapse', width:'100%'}}>
            <thead>
              <tr>
                <th style={th}>ID</th>
                <th style={th}>Código</th>
                <th style={th}>Nombre</th>
                <th style={th}>Estado</th>
                <th style={th}>Prioridad</th>
                <th style={th}>Avance %</th>
                <th style={th}>Presupuesto</th>
              </tr>
            </thead>
            <tbody>
              {items.map(p => (
                <tr key={p.id}>
                  <td style={td}>{p.id}</td>
                  <td style={td}>{p.codigo || ''}</td>
                  <td style={td}>{p.nombre}</td>
                  <td style={td}>{p.estado}</td>
                  <td style={td}>{p.prioridad}</td>
                  <td style={td}>{p.avance_pct}</td>
                  <td style={td}>{p.presupuesto_monto}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )
      }
    </div>
  );
}

const th: React.CSSProperties = { textAlign:'left', borderBottom:'1px solid #ddd', padding:'6px 4px' };
const td: React.CSSProperties = { borderBottom:'1px solid #f0f0f0', padding:'6px 4px' };
