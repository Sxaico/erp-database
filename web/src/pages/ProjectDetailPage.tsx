// web/src/pages/ProjectDetailPage.tsx
import { useEffect, useMemo, useState } from "react";
import { useParams, Link } from "react-router-dom";
import { createTask, getProjectTasks, Task, updateTask } from "../api/projects";

const ESTADOS: Task["estado"][] = ["PENDIENTE", "EN_PROGRESO", "BLOQUEADA", "HECHA"];

export default function ProjectDetailPage() {
  const params = useParams();
  const projectId = useMemo(() => Number(params.id), [params.id]);
  const [tasks, setTasks] = useState<Task[]>([]);
  const [loading, setLoading] = useState(true);
  const [err, setErr] = useState<string | null>(null);

  const [titulo, setTitulo] = useState("");
  const [descripcion, setDescripcion] = useState("");

  async function refresh() {
    setLoading(true);
    setErr(null);
    try {
      setTasks(await getProjectTasks(projectId));
    } catch (e: any) {
      setErr(e?.message || "Error cargando tareas");
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    if (!Number.isFinite(projectId)) return;
    refresh();
  }, [projectId]);

  async function onCreate(e: React.FormEvent) {
    e.preventDefault();
    if (!titulo.trim()) return;
    try {
      await createTask({ proyecto_id: projectId, titulo, descripcion });
      setTitulo("");
      setDescripcion("");
      await refresh();
    } catch (e: any) {
      alert(e?.message || "Error creando tarea");
    }
  }

  async function onChangeState(t: Task, estado: Task["estado"]) {
    try {
      const updated = await updateTask(t.id, { estado });
      setTasks((prev) => prev.map((x) => (x.id === t.id ? updated : x)));
    } catch (e: any) {
      alert(e?.message || "Error actualizando estado");
    }
  }

  if (!Number.isFinite(projectId)) return <p className="p-4">Proyecto inválido.</p>;
  if (loading) return <p className="p-4">Cargando...</p>;
  if (err) return <p className="p-4" style={{ color: "crimson" }}>{err}</p>;

  return (
    <div className="p-4 max-w-3xl mx-auto">
      <div className="mb-4">
        <Link className="underline" to="/projects">← Volver</Link>
      </div>
      <h1 className="text-2xl font-semibold mb-3">Proyecto #{projectId}</h1>

      <form onSubmit={onCreate} className="border rounded p-3 mb-6 space-y-2">
        <div className="font-medium">Nueva tarea</div>
        <input
          value={titulo}
          onChange={(e) => setTitulo(e.target.value)}
          placeholder="Título"
          className="w-full border rounded p-2"
        />
        <textarea
          value={descripcion}
          onChange={(e) => setDescripcion(e.target.value)}
          placeholder="Descripción (opcional)"
          className="w-full border rounded p-2"
        />
        <button className="border rounded px-3 py-1" type="submit">Crear</button>
      </form>

      <h2 className="text-xl font-semibold mb-2">Tareas</h2>
      {tasks.length === 0 ? (
        <p>No hay tareas.</p>
      ) : (
        <ul className="space-y-2">
          {tasks.map((t) => (
            <li key={t.id} className="border rounded p-3">
              <div className="flex items-center justify-between gap-4">
                <div>
                  <div className="font-medium">{t.titulo}</div>
                  {t.descripcion && (
                    <div className="text-sm text-gray-600">{t.descripcion}</div>
                  )}
                  <div className="text-sm text-gray-700 mt-1">
                    Estado: <b>{t.estado}</b> · Prioridad: {t.prioridad}
                  </div>
                </div>
                <select
                  className="border rounded p-1"
                  value={t.estado}
                  onChange={(e) => onChangeState(t, e.target.value as Task["estado"])}
                >
                  {ESTADOS.map((s) => (
                    <option key={s} value={s}>{s}</option>
                  ))}
                </select>
              </div>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
