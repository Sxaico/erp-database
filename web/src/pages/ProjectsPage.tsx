// web/src/pages/ProjectsPage.tsx
import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { apiFetch } from "../lib/api";

type Proyecto = {
  id: number;
  uuid: string;
  codigo?: string | null;
  nombre: string;
  estado: string;
  prioridad: number;
  avance_pct?: number | null;
  presupuesto_monto?: number | null;
};

export default function ProjectsPage() {
  const [items, setItems] = useState<Proyecto[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [nuevo, setNuevo] = useState({ codigo: "", nombre: "", descripcion: "" });
  const [saving, setSaving] = useState(false);

  const load = async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await apiFetch<Proyecto[]>("/api/projects");
      setItems(data);
    } catch (e: any) {
      setError(e.message || "Error al cargar proyectos");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    load();
  }, []);

  const createProject = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!nuevo.nombre.trim()) return;
    setSaving(true);
    try {
      await apiFetch<Proyecto>("/api/projects", {
        method: "POST",
        json: {
          codigo: nuevo.codigo || null,
          nombre: nuevo.nombre,
          descripcion: nuevo.descripcion || null,
          prioridad: 2,
        },
      });
      setNuevo({ codigo: "", nombre: "", descripcion: "" });
      await load();
    } catch (e: any) {
      alert(e.message || "Error al crear proyecto");
    } finally {
      setSaving(false);
    }
  };

  return (
    <div style={{ maxWidth: 900, margin: "0 auto", padding: 16 }}>
      <h1>Proyectos</h1>

      <form onSubmit={createProject} style={{ display: "grid", gap: 8, marginBottom: 24 }}>
        <input
          placeholder="Código (opcional)"
          value={nuevo.codigo}
          onChange={(e) => setNuevo({ ...nuevo, codigo: e.target.value })}
        />
        <input
          placeholder="Nombre *"
          required
          value={nuevo.nombre}
          onChange={(e) => setNuevo({ ...nuevo, nombre: e.target.value })}
        />
        <input
          placeholder="Descripción (opcional)"
          value={nuevo.descripcion}
          onChange={(e) => setNuevo({ ...nuevo, descripcion: e.target.value })}
        />
        <button type="submit" disabled={saving}>
          {saving ? "Creando..." : "Crear proyecto"}
        </button>
      </form>

      {loading && <p>Cargando...</p>}
      {error && <p style={{ color: "crimson" }}>{error}</p>}

      {!loading && !error && (
        <table width="100%" cellPadding={8} style={{ borderCollapse: "collapse" }}>
          <thead>
            <tr>
              <th align="left">ID</th>
              <th align="left">Código</th>
              <th align="left">Nombre</th>
              <th align="left">Estado</th>
              <th align="left">Acciones</th>
            </tr>
          </thead>
          <tbody>
            {items.map((p) => (
              <tr key={p.id} style={{ borderTop: "1px solid #eee" }}>
                <td>{p.id}</td>
                <td>{p.codigo || "-"}</td>
                <td>{p.nombre}</td>
                <td>{p.estado}</td>
                <td>
                  <Link to={`/projects/${p.id}`}>Ver</Link>
                </td>
              </tr>
            ))}
            {items.length === 0 && (
              <tr>
                <td colSpan={5} style={{ textAlign: "center", padding: 24 }}>
                  Sin proyectos
                </td>
              </tr>
            )}
          </tbody>
        </table>
      )}
    </div>
  );
}
