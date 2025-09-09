// web/src/api/client.ts
import { getAccessToken, getRefreshToken, setSession, clearSession } from "./auth";

const API_BASE = "http://localhost:8000";

type HttpMethod = "GET" | "POST" | "PATCH" | "DELETE";
type ReqOpts = { method?: HttpMethod; body?: any; headers?: Record<string,string> };

async function refreshAccessToken(): Promise<boolean> {
  const rt = getRefreshToken();
  if (!rt) return false;
  const res = await fetch(`${API_BASE}/api/auth/refresh`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ refresh_token: rt })
  });
  if (!res.ok) return false;
  const data = await res.json(); // { access_token, expires_in, ... }
  setSession(data.access_token, rt);
  return true;
}

export async function fetchJson<T = any>(path: string, opts: ReqOpts = {}, retry = true): Promise<T> {
  const headers: Record<string,string> = {
    "Content-Type": "application/json",
    ...(opts.headers || {})
  };
  const at = getAccessToken();
  if (at) headers.Authorization = `Bearer ${at}`;

  const res = await fetch(`${API_BASE}${path}`, {
    method: opts.method || "GET",
    headers,
    body: opts.body ? JSON.stringify(opts.body) : undefined
  });

  if (res.status === 401 && retry) {
    const ok = await refreshAccessToken();
    if (ok) return fetchJson<T>(path, opts, false);
    clearSession();
    throw new Error("Sesión expirada");
  }

  if (!res.ok) {
    const err = await res.text();
    throw new Error(err || `Error HTTP ${res.status}`);
  }
  return res.status === 204 ? (undefined as T) : await res.json();
}

export const api = {
  get: <T>(p: string) => fetchJson<T>(p),
  post: <T>(p: string, b?: any) => fetchJson<T>(p, { method: "POST", body: b }),
  patch: <T>(p: string, b?: any) => fetchJson<T>(p, { method: "PATCH", body: b }),
  del: <T>(p: string) => fetchJson<T>(p, { method: "DELETE" }),
};
