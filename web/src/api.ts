// src/api.ts
export interface Role { id: number; nombre: string; }
export interface User {
  id: number; email: string; nombre: string; apellido: string;
  roles: Role[]; activo: boolean;
}
export interface Tokens { access_token: string; refresh_token?: string; token_type?: string; expires_in?: number; }
export interface Project {
  id: number; uuid: string; codigo: string | null; nombre: string;
  estado: string; prioridad: number; avance_pct: number; presupuesto_monto: number;
}
export interface HealthResponse { status: string; db: string; version: string; }

const API_BASE =
  (import.meta as any).env?.VITE_API_URL ||
  window.location.origin.replace(':5173', ':8000');

const AT_KEY = 'erp.at';
const RT_KEY = 'erp.rt';

export const tokenStore = {
  get access() { return localStorage.getItem(AT_KEY) || ''; },
  set access(v: string) { localStorage.setItem(AT_KEY, v); },
  get refresh() { return localStorage.getItem(RT_KEY) || ''; },
  set refresh(v: string) { localStorage.setItem(RT_KEY, v); },
  clear() { localStorage.removeItem(AT_KEY); localStorage.removeItem(RT_KEY); }
};

async function refreshAccessToken(): Promise<string | null> {
  const rt = tokenStore.refresh;
  if (!rt) return null;
  const res = await fetch(`${API_BASE}/api/auth/refresh`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ refresh_token: rt })
  });
  if (!res.ok) return null;
  const data = await res.json() as Tokens;
  if (data.access_token) {
    tokenStore.access = data.access_token;
    return data.access_token;
  }
  return null;
}

async function request<T>(path: string, init?: RequestInit, retry = true): Promise<T> {
  const headers = new Headers(init?.headers || {});
  if (!headers.has('Content-Type') && init?.body) headers.set('Content-Type', 'application/json');
  const at = tokenStore.access;
  if (at) headers.set('Authorization', `Bearer ${at}`);

  const res = await fetch(`${API_BASE}${path}`, { ...init, headers });
  if (res.status === 401 && retry) {
    const newAT = await refreshAccessToken();
    if (newAT) {
      const headers2 = new Headers(init?.headers || {});
      if (!headers2.has('Content-Type') && init?.body) headers2.set('Content-Type', 'application/json');
      headers2.set('Authorization', `Bearer ${newAT}`);
      const res2 = await fetch(`${API_BASE}${path}`, { ...init, headers: headers2 });
      if (!res2.ok) throw new Error(`${res2.status} ${res2.statusText}`);
      return res2.json() as Promise<T>;
    }
  }
  if (!res.ok) throw new Error(`${res.status} ${res.statusText}`);
  return res.json() as Promise<T>;
}

export const api = {
  async login(email: string, password: string): Promise<User> {
    const res = await fetch(`${API_BASE}/api/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password })
    });
    if (!res.ok) throw new Error('Credenciales inválidas');
    const data = await res.json() as Tokens & User; // login retorna tokens + (a veces user). Cubrimos tokens seguro.
    if (data.access_token) tokenStore.access = data.access_token;
    if (data.refresh_token) tokenStore.refresh = data.refresh_token;
    // Aseguramos el user llamando a /me:
    return this.me();
  },
  me(): Promise<User> {
    return request<User>('/api/auth/me');
  },
  health(): Promise<HealthResponse> {
    return request<HealthResponse>('/health', { method: 'GET' });
  },
  projects: {
    list(): Promise<Project[]> {
      return request<Project[]>('/api/projects', { method: 'GET' });
    },
    create(payload: { nombre: string; descripcion?: string }): Promise<Project> {
      return request<Project>('/api/projects', {
        method: 'POST',
        body: JSON.stringify(payload)
      });
    }
  }
};
