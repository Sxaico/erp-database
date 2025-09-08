import React, {createContext, useContext, useEffect, useMemo, useRef, useState} from "react";

type Rol = { id: number; nombre: string; descripcion?: string; activo: boolean; created_at: string };
type Departamento = { id: number; nombre: string; descripcion?: string };

export type User = {
  id: number;
  uuid: string;
  email: string;
  nombre: string;
  apellido: string;
  nombre_completo: string;
  telefono?: string | null;
  activo: boolean;
  ultimo_login?: string | null;
  created_at: string;
  roles: Rol[];
  departamentos: Departamento[];
};

type LoginResponse = {
  access_token: string;
  refresh_token: string;
  token_type: "bearer";
  expires_in: number; // seconds
  user: User;
};

type TokenRefreshResponse = {
  access_token: string;
  token_type: "bearer";
  expires_in: number;
};

type AuthState = {
  user: User | null;
  accessToken: string | null;
  refreshToken: string | null;
  // epoch (ms) cuando expira el access
  accessExp: number | null;
};

type AuthContextType = {
  user: User | null;
  isAuthenticated: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
  getAccessToken: () => Promise<string | null>;
};

const AuthContext = createContext<AuthContextType | undefined>(undefined);

const STORAGE_KEY = "erp_auth_v1";
const API = import.meta.env.VITE_API_URL ?? "http://localhost:8000";

function loadStorage(): AuthState {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return { user: null, accessToken: null, refreshToken: null, accessExp: null };
    return JSON.parse(raw);
  } catch {
    return { user: null, accessToken: null, refreshToken: null, accessExp: null };
  }
}

function saveStorage(s: AuthState) {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(s));
}

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [state, setState] = useState<AuthState>(() => loadStorage());
  const timerRef = useRef<number | null>(null);

  const scheduleRefresh = (secondsFromNow: number) => {
    if (timerRef.current) window.clearTimeout(timerRef.current);
    // refrescar 60s antes del vencimiento (o a los 60s si el token dura muy poco)
    const ms = Math.max((secondsFromNow - 60) * 1000, 60_000);
    timerRef.current = window.setTimeout(() => {
      void refreshAccess();
    }, ms) as unknown as number;
  };

  const setAuth = (next: AuthState) => {
    setState(next);
    saveStorage(next);
    if (next.accessExp && next.accessToken) {
      const now = Date.now();
      const secondsLeft = Math.max(1, Math.floor((next.accessExp - now) / 1000));
      scheduleRefresh(secondsLeft);
    } else if (timerRef.current) {
      window.clearTimeout(timerRef.current);
      timerRef.current = null;
    }
  };

  const login = async (email: string, password: string) => {
    const resp = await fetch(`${API}/api/auth/login`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email, password })
    });
    if (!resp.ok) {
      const err = await resp.json().catch(() => ({}));
      throw new Error(err?.detail || "Error de login");
    }
    const data: LoginResponse = await resp.json();
    const exp = Date.now() + data.expires_in * 1000;
    setAuth({
      user: data.user,
      accessToken: data.access_token,
      refreshToken: data.refresh_token,
      accessExp: exp
    });
  };

  const refreshAccess = async (): Promise<string | null> => {
    if (!state.refreshToken) return null;
    try {
      const resp = await fetch(`${API}/api/auth/refresh`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ refresh_token: state.refreshToken })
      });
      if (!resp.ok) throw new Error("No se pudo refrescar sesión");
      const data: TokenRefreshResponse = await resp.json();
      const exp = Date.now() + data.expires_in * 1000;
      const next: AuthState = {
        ...state,
        accessToken: data.access_token,
        accessExp: exp
      };
      setAuth(next);
      return data.access_token;
    } catch {
      // refresh inválido: cerrar sesión
      logout();
      return null;
    }
  };

  const logout = () => {
    setAuth({ user: null, accessToken: null, refreshToken: null, accessExp: null });
  };

  const getAccessToken = async () => {
    // si falta poco, refrescamos
    if (state.accessExp && state.accessExp - Date.now() < 60_000) {
      return await refreshAccess();
    }
    return state.accessToken;
  };

  // bootstrap: si tengo token, intento traer /me para confirmar usuario
  useEffect(() => {
    const boot = async () => {
      if (!state.accessToken) return;
      try {
        const resp = await fetch(`${API}/api/auth/me`, {
          headers: { Authorization: `Bearer ${state.accessToken}` }
        });
        if (!resp.ok) throw new Error("Token inválido");
        const user: User = await resp.json();
        setAuth({ ...state, user });
      } catch {
        logout();
      }
    };
    void boot();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const value = useMemo<AuthContextType>(() => ({
    user: state.user,
    isAuthenticated: !!state.accessToken && !!state.user,
    login,
    logout,
    getAccessToken
  }), [state.user, state.accessToken, state.accessExp]);

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};

export const useAuth = () => {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth debe usarse dentro de <AuthProvider>");
  return ctx;
};
