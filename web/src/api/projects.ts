// web/src/api/projects.ts
import { apiFetch } from "./client";

export type Project = {
  id: number;
  uuid: string;
  codigo: string | null;
  nombre: string;
  estado: string;
  prioridad: number;
  avance_pct: number;
  presupuesto_monto: number;
};

export type Task = {
  id: number;
  proyecto_id: number;
  titulo: string;
  descripcion?: string | null;
  estado: "PENDIENTE" | "EN_PROGRESO" | "BLOQUEADA" | "HECHA";
  prioridad: number;
};

export async function getProjects(): Promise<Project[]> {
  return apiFetch<Project[]>("/api/projects");
}

export async function getProjectTasks(projectId: number): Promise<Task[]> {
  return apiFetch<Task[]>(`/api/projects/${projectId}/tasks`);
}

export async function createTask(input: {
  proyecto_id: number;
  titulo: string;
  descripcion?: string;
  prioridad?: number;
}): Promise<Task> {
  return apiFetch<Task>("/api/projects/tasks", {
    method: "POST",
    body: JSON.stringify(input),
  });
}

export async function updateTask(
  taskId: number,
  patch: Partial<Pick<Task, "titulo" | "descripcion" | "prioridad" | "estado">>
): Promise<Task> {
  return apiFetch<Task>(`/api/projects/tasks/${taskId}`, {
    method: "PATCH",
    body: JSON.stringify(patch),
  });
}
