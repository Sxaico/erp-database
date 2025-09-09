// web/src/api.ts
export type User = {
  id: number; email: string; nombre: string; apellido: string;
  roles: { id: number; nombre: string }[];
};

export type Project = {
  id: number; uuid: string; codigo?: string | null;
  nombre: string; estado: string; prioridad: number;
  avance_pct?: number | null; presupuesto_monto?: number | null;
};

export type Task = {
  id: number; uuid: string; proyecto_id: number;
  titulo: string; estado: string; prioridad: number;
};

export type EstadoReportItem = { estado: string; cantidad: number };

const API = (import.meta as any).env?.VITE_API_URL ?? "http://localhost:8000";

const LS = {
  access: "erp.access_token",
  refresh: "erp.refresh_token",
  user: "erp.user",
};

function getAccessToken() { return localStorage.getItem(LS.access) || ""; }
function getRefreshToken() { return localStorage.getItem(LS.refresh) || ""; }
function setTokens(at?: string, rt?: string) {
  if (at) localStorage.setItem(LS.access, at);
  if (rt) localStorage.setItem(LS.refresh, rt);
}
export function logout() {
  localStorage.removeItem(LS.access);
  localStorage.removeItem(LS.refresh);
  localStorage.removeItem(LS.user);
}

async function raw(path: string, init: RequestInit = {}) {
  const url = path.startsWith("http") ? path : `${API}${path}`;
  return fetch(url, init);
}

async function request(path: string, init: RequestInit = {}, retried = false) {
  const headers: Record<string, string> = {
    "Content-Type": "application/json",
    ...(init.headers as any),
  };
  const at = getAccessToken();
  if (at) headers.Authorization = `Bearer ${at}`;

  let res = await raw(path, { ...init, headers });
  if (res.status === 401 && !retried) {
    const rt = getRefreshToken();
    if (!rt) throw new Error("No autenticado");
    const r = await raw("/api/auth/refresh", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ refresh_token: rt }),
    });
    if (r.ok) {
      const data = await r.json();
      setTokens(data.access_token);
      // reintenta 1 vez con nuevo AT
      const headers2 = { ...headers, Authorization: `Bearer ${getAccessToken()}` };
      res = await raw(path, { ...init, headers: headers2 });
    } else {
      logout();
      throw new Error("Sesión expirada");
    }
  }
  if (!res.ok) {
    const msg = (await res.text()) || `HTTP ${res.status}`;
    throw new Error(msg);
  }
  const text = await res.text();
  return text ? JSON.parse(text) : null;
}

// ---------- Auth ----------
export async function login(email: string, password: string) {
  const data = await request("/api/auth/login", {
    method: "POST",
    body: JSON.stringify({ email, password }),
  });
  setTokens(data.access_token, data.refresh_token);
  localStorage.setItem(LS.user, JSON.stringify(data.user));
  return data.user as User;
}

export function currentUser(): User | null {
  const raw = localStorage.getItem(LS.user);
  return raw ? JSON.parse(raw) : null;
}

export function isLoggedIn() {
  return !!getAccessToken();
}

// ---------- Projects ----------
export async function fetchProjects(): Promise<Project[]> {
  return request("/api/projects", { method: "GET" });
}
export async function createProject(payload: {
  codigo?: string; nombre: string; descripcion?: string; prioridad?: number;
}): Promise<Project> {
  return request("/api/projects", { method: "POST", body: JSON.stringify(payload) });
}

// ---------- Tasks ----------
export async function fetchTasks(projectId: number): Promise<Task[]> {
  return request(`/api/projects/${projectId}/tasks`);
}
export async function createTask(payload: {
  proyecto_id: number; titulo: string; descripcion?: string; prioridad?: number;
}): Promise<Task> {
  return request(`/api/projects/tasks`, { method: "POST", body: JSON.stringify(payload) });
}
export async function patchTask(taskId: number, partial: Partial<Task>): Promise<Task> {
  return request(`/api/projects/tasks/${taskId}`, { method: "PATCH", body: JSON.stringify(partial) });
}

// ---------- Report ----------
export async function fetchEstadoReport(projectId: number): Promise<EstadoReportItem[]> {
  return request(`/api/projects/${projectId}/report/estado`);
}
