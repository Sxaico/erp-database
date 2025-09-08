// web/src/pages/ProjectsPage.tsx
import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { getProjects, Project } from "../api/projects";

export default function ProjectsPage() {
  const [items, setItems] = useState<Project[]>([]);
  const [loading, setLoading] = useState(true);
  const [err, setErr] = useState<string | null>(null);

  useEffect(() => {
    (async () => {
      try {
        setItems(await getProjects());
      } catch (e: any) {
        setErr(e?.message || "Error cargando proyectos");
      } finally {
        setLoading(false);
      }
    })();
  }, []);

  if (loading) return <p className="p-4">Cargando proyectos...</p>;
  if (err) return <p className="p-4" style={{ color: "crimson" }}>{err}</p>;

  return (
    <div className="p-4 max-w-3xl mx-auto">
      <h1 className="text-2xl font-semibold mb-4">Proyectos</h1>
      {items.length === 0 ? (
        <p>No hay proyectos.</p>
      ) : (
        <ul className="space-y-2">
          {items.map((p) => (
            <li key={p.id} className="border rounded p-3">
              <div className="flex items-center justify-between">
                <div>
                  <div className="font-medium">{p.nombre}</div>
                  <div className="text-sm text-gray-600">
                    Estado: {p.estado} · Prioridad: {p.prioridad} · Avance: {p.avance_pct}%
                  </div>
                </div>
                <Link className="underline" to={`/projects/${p.id}`}>
                  Ver
                </Link>
              </div>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
