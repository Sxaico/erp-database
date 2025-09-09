// web/src/api.ts
const API_BASE = (import.meta as any).env?.VITE_API_BASE || "http://localhost:8000";

type LoginResp = {
  access_token: string;
  refresh_token: string;
  expires_in: number;
  user: any;
};

type RefreshResp = {
  access_token: string;
  expires_in: number;
};

const storage = {
  get access() { return localStorage.getItem("access_token"); },
  set access(v: string | null) { v ? localStorage.setItem("access_token", v) : localStorage.removeItem("access_token"); },
  get refresh() { return localStorage.getItem("refresh_token"); },
  set refresh(v: string | null) { v ? localStorage.setItem("refresh_token", v) : localStorage.removeItem("refresh_token"); },
  get exp() { const v = localStorage.getItem("access_exp"); return v ? parseInt(v) : 0; },
  set exp(ts: number | null) { ts ? localStorage.setItem("access_exp", String(ts)) : localStorage.removeItem("access_exp"); },
  clear() { this.access = null; this.refresh = null; this.exp = null; }
};

export function isAuthenticated() {
  return !!storage.access;
}

export async function login(email: string, password: string) {
  const r = await fetch(`${API_BASE}/api/auth/login`, {
    method: "POST",
    headers: {"Content-Type":"application/json"},
    body: JSON.stringify({ email, password })
  });
  if (!r.ok) throw new Error("Credenciales inválidas");
  const data = (await r.json()) as LoginResp;
  storage.access = data.access_token;
  storage.refresh = data.refresh_token;
  storage.exp = Date.now() + data.expires_in * 1000;
  return data;
}

export function logout() {
  storage.clear();
}

async function refreshAccessToken(): Promise<void> {
  if (!storage.refresh) throw new Error("No refresh token");
  const r = await fetch(`${API_BASE}/api/auth/refresh`, {
    method: "POST",
    headers: {"Content-Type":"application/json"},
    body: JSON.stringify({ refresh_token: storage.refresh })
  });
  if (!r.ok) throw new Error("Refresh inválido");
  const data = (await r.json()) as RefreshResp;
  storage.access = data.access_token;
  storage.exp = Date.now() + data.expires_in * 1000;
}

let refreshing = false;

export async function apiFetch<T = any>(
  path: string,
  opts: RequestInit = {},
  _retry = false
): Promise<T> {
  const headers: Record<string,string> = {
    "Content-Type": "application/json",
    ...(opts.headers as Record<string,string> || {})
  };
  if (storage.access) headers.Authorization = `Bearer ${storage.access}`;

  const res = await fetch(`${API_BASE}${path}`, { ...opts, headers });

  if (res.status === 401 && storage.refresh && !_retry) {
    // intenta refresh una vez
    if (!refreshing) {
      refreshing = true;
      try { await refreshAccessToken(); }
      finally { refreshing = false; }
    } else {
      // si otro request ya refresca, esperá un tick corto
      await new Promise(r => setTimeout(r, 250));
    }
    return apiFetch<T>(path, opts, true);
  }

  if (res.status === 204) return null as unknown as T;
  if (!res.ok) {
    const msg = await res.text().catch(()=> "Error");
    throw new Error(msg || `HTTP ${res.status}`);
  }
  return res.json();
}

// --- APIs específicas ---
export type Project = {
  id: number; uuid: string; codigo: string|null; nombre: string;
  estado: string; prioridad: number; avance_pct: number|null; presupuesto_monto: number|null;
};

export type Task = {
  id: number; uuid: string; proyecto_id: number;
  titulo: string; estado: string; prioridad: number; real_horas: number|null;
};

export async function fetchProjects(): Promise<Project[]> {
  return apiFetch<Project[]>("/api/projects");
}

export async function createProject(input: { nombre: string; codigo?: string|null; descripcion?: string|null; prioridad?: number; }): Promise<Project> {
  return apiFetch<Project>("/api/projects", { method: "POST", body: JSON.stringify(input) });
}

export async function fetchTasks(projectId: number): Promise<Task[]> {
  return apiFetch<Task[]>(`/api/projects/${projectId}/tasks`);
}

export async function createTask(input: { proyecto_id: number; titulo: string; descripcion?: string|null; prioridad?: number; }): Promise<Task> {
  return apiFetch<Task>("/api/projects/tasks", { method: "POST", body: JSON.stringify(input) });
}

export async function patchTask(taskId: number, patch: Partial<Pick<Task,"titulo"|"descripcion"|"prioridad"|"estado">>) {
  return apiFetch<Task>(`/api/projects/tasks/${taskId}`, { method: "PATCH", body: JSON.stringify(patch) });
}

export async function fetchEstadoReport(projectId: number): Promise<{ proyecto_id:number; proyecto:string; estado:string; cantidad:number; }[]> {
  return apiFetch(`/api/projects/${projectId}/report/estado`);
}
