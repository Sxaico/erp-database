// web/src/lib/api.ts
const BASE = import.meta.env.VITE_API_URL || "http://localhost:8000";

type FetchOpts = RequestInit & { json?: any };

function buildHeaders(access?: string, extra?: HeadersInit): HeadersInit {
  const base: Record<string, string> = { "Content-Type": "application/json" };
  if (access) base.Authorization = `Bearer ${access}`;
  return { ...base, ...(extra || {}) }; // <-- corrección
}

function getAuthFromStorage() {
  try {
    return JSON.parse(localStorage.getItem("auth") || "{}");
  } catch {
    return {};
  }
}

function saveAuthToStorage(auth: any) {
  localStorage.setItem("auth", JSON.stringify(auth));
}

async function refreshAccessToken(refresh_token: string) {
  const res = await fetch(`${BASE}/api/auth/refresh`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ refresh_token }),
  });
  if (!res.ok) throw new Error("Refresh inválido");
  const data = await res.json();
  return data as { access_token: string; expires_in: number; token_type: string };
}

/**
 * apiFetch — hace fetch con Bearer y, si recibe 401, intenta 1 refresh y reintenta.
 * - Guarda el nuevo access_token en localStorage.auth
 * - Si falla el refresh, limpia sesión (auth) y lanza error
 */
export async function apiFetch<T = any>(path: string, opts: FetchOpts = {}): Promise<T> {
  const auth = getAuthFromStorage();
  const access = auth?.access_token as string | undefined;
  const refresh = auth?.refresh_token as string | undefined;

  const headers = buildHeaders(access, opts.headers);
  const body = opts.json !== undefined ? JSON.stringify(opts.json) : opts.body;

  let res = await fetch(`${BASE}${path}`, { ...opts, headers, body });

  if (res.status === 401 && refresh) {
    // intentar refresh una sola vez
    try {
      const r = await refreshAccessToken(refresh);
      const updated = { ...auth, access_token: r.access_token, expires_in: r.expires_in };
      saveAuthToStorage(updated);

      const retryHeaders = buildHeaders(r.access_token, opts.headers);
      res = await fetch(`${BASE}${path}`, { ...opts, headers: retryHeaders, body });
    } catch (e) {
      localStorage.removeItem("auth");
      throw new Error("Sesión expirada. Vuelve a iniciar sesión.");
    }
  }

  if (!res.ok) {
    // intentar parsear JSON de error, si existe
    let msg = res.statusText;
    try {
      const err = await res.json();
      msg = err?.detail || JSON.stringify(err);
    } catch {}
    throw new Error(msg || "Error de solicitud");
  }

  const ct = res.headers.get("content-type") || "";
  if (ct.includes("application/json")) {
    return (await res.json()) as T;
  }
  // por si alguna llamada devuelve vacío
  return undefined as T;
}
