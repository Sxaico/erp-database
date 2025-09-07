// web/src/api.ts
import { LoginResponse, Proyecto, Tarea, ResumenEstadoItem } from "./types";

const JSON_HEADERS = { "Content-Type": "application/json" };

function getToken(): string | null {
  try {
    return sessionStorage.getItem("access_token");
  } catch {
    return null;
  }
}

async function request<T>(
  path: string,
  opts: RequestInit = {},
  auth: boolean = true
): Promise<T> {
  const headers = new Headers(opts.headers || {});
  if (!headers.has("Content-Type") && opts.body && typeof opts.body === "string") {
    headers.set("Content-Type", "application/json");
  }
  if (auth) {
    const token = getToken();
    if (token) headers.set("Authorization", `Bearer ${token}`);
  }

  const resp = await fetch(path, { ...opts, headers });
  if (resp.status === 401) {
    // Para MVP: si 401 → deslogueo
    sessionStorage.removeItem("access_token");
    sessionStorage.removeItem("user");
    // Devolvemos error entendible
    throw new Error("No autorizado. Iniciá sesión nuevamente.");
  }
  if (!resp.ok) {
    const text = await resp.text();
    throw new Error(text || `Error HTTP ${resp.status}`);
  }
  if (resp.status === 204) return undefined as unknown as T;
  return (await resp.json()) as T;
}

// ---- Auth ----
export async function apiLogin(email: string, password: string): Promise<LoginResponse> {
  return request<LoginResponse>("/api/auth/login", {
    method: "POST",
    headers: JSON_HEADERS,
    body: JSON.stringify({ email, password }),
  }, false);
}

// ---- Projects ----
export async function apiListProjects(): Promise<Proyecto[]> {
  return request<Proyecto[]>("/api/projects");
}

export async function apiGetProject(id: number): Promise<Proyecto> {
  return request<Proyecto>(`/api/projects/${id}`);
}

export async function apiListTasks(projectId: number): Promise<Tarea[]> {
  return request<Tarea[]>(`/api/projects/${projectId}/tasks`);
}

export async function apiCreateTask(payload: {
  proyecto_id: number;
  titulo: string;
  descripcion?: string | null;
  prioridad?: number;
}): Promise<Tarea> {
  return request<Tarea>("/api/projects/tasks", {
    method: "POST",
    headers: JSON_HEADERS,
    body: JSON.stringify(payload),
  });
}

export async function apiUpdateTask(taskId: number, patch: Partial<Tarea>): Promise<Tarea> {
  return request<Tarea>(`/api/projects/tasks/${taskId}`, {
    method: "PATCH",
    headers: JSON_HEADERS,
    body: JSON.stringify(patch),
  });
}

export async function apiResumenEstado(projectId: number): Promise<ResumenEstadoItem[]> {
  return request<ResumenEstadoItem[]>(`/api/projects/${projectId}/report/estado`);
}
