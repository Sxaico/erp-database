let ACCESS_TOKEN: string | null = null;

// Permite al AuthContext mantener sincronizado el token
export function apiSetAccessToken(token: string | null) {
  ACCESS_TOKEN = token;
}

function baseUrl() {
  const url = import.meta.env.VITE_API_URL;
  if (!url) throw new Error("Falta VITE_API_URL en web/.env");
  return url;
}

async function tryRefresh(): Promise<boolean> {
  const refresh = localStorage.getItem("refresh_token");
  if (!refresh) return false;
  try {
    const res = await fetch(baseUrl() + "/api/auth/refresh", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ refresh_token: refresh }),
    });
    if (!res.ok) return false;
    const data = await res.json();
    if (data?.access_token) {
      localStorage.setItem("access_token", data.access_token);
      ACCESS_TOKEN = data.access_token;
      return true;
    }
  } catch {}
  return false;
}

export async function apiFetch<T = any>(
  path: string,
  opts: RequestInit = {},
  retryOn401 = true
): Promise<T> {
  const headers = new Headers(opts.headers || {});
  headers.set("Accept", "application/json");
  if (!(opts.body instanceof FormData)) {
    headers.set("Content-Type", headers.get("Content-Type") || "application/json");
  }
  if (ACCESS_TOKEN) headers.set("Authorization", `Bearer ${ACCESS_TOKEN}`);

  const res = await fetch(baseUrl() + path, { ...opts, headers });

  if (res.status === 401 && retryOn401) {
    const refreshed = await tryRefresh();
    if (refreshed) {
      // reintenta una vez
      return apiFetch<T>(path, opts, false);
    }
  }
  if (!res.ok) {
    const err = await res.json().catch(() => ({}));
    throw new Error(err?.detail || `HTTP ${res.status}`);
  }
  // si no hay contenido
  if (res.status === 204) return null as T;
  return (await res.json()) as T;
}
