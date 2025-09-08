import { Task } from "../types";
const ESTADOS = ["PENDIENTE", "EN_PROGRESO", "BLOQUEADA", "HECHA"] as const;

export default function TaskRow({
  task,
  onChangeEstado,
}: {
  task: Task;
  onChangeEstado: (estado: Task["estado"]) => void;
}) {
  return (
    <div className="flex items-center justify-between border rounded p-2">
      <div>
        <div className="font-medium">{task.titulo}</div>
        {task.descripcion && <div className="text-sm text-gray-600">{task.descripcion}</div>}
      </div>
      <div className="flex items-center gap-2">
        <label className="text-sm text-gray-600">Estado</label>
        <select
          className="border rounded p-1"
          value={task.estado}
          onChange={(e) => onChangeEstado(e.target.value as Task["estado"])}
        >
          {ESTADOS.map(e => <option key={e} value={e}>{e}</option>)}
        </select>
      </div>
    </div>
  );
}
