import React, { createContext, useContext, useEffect, useMemo, useState } from "react";
import { apiFetch, apiSetAccessToken } from "../lib/api";

type Rol = { id: number; nombre: string; descripcion?: string; activo: boolean; created_at: string };
type Depto = { id: number; nombre: string; descripcion?: string };

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
  departamentos: Depto[];
};

type LoginResponse = {
  access_token: string;
  refresh_token: string;
  token_type: "bearer";
  expires_in: number;
  user: User;
};

type AuthContextValue = {
  user: User | null;
  accessToken: string | null;
  refreshToken: string | null;
  isAuthenticated: boolean;
  loading: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
};

const AuthContext = createContext<AuthContextValue | undefined>(undefined);

const ACCESS_KEY = "access_token";
const REFRESH_KEY = "refresh_token";
const USER_KEY = "auth_user";

export const AuthProvider: React.FC<React.PropsWithChildren> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [accessToken, setAccessToken] = useState<string | null>(null);
  const [refreshToken, setRefreshToken] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  // Cargar desde localStorage y validar con /api/auth/me
  useEffect(() => {
    const at = localStorage.getItem(ACCESS_KEY);
    const rt = localStorage.getItem(REFRESH_KEY);
    const uRaw = localStorage.getItem(USER_KEY);
    if (at) apiSetAccessToken(at);
    if (at && uRaw) {
      setAccessToken(at);
      setRefreshToken(rt);
      try {
        const u = JSON.parse(uRaw) as User;
        setUser(u);
      } catch {}
    }
    (async () => {
      try {
        if (at) {
          const me = await apiFetch("/api/auth/me");
          setUser(me as User);
        } else {
          setUser(null);
        }
      } catch {
        // si falla, limpiamos
        doLogout();
      } finally {
        setLoading(false);
      }
    })();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const doLogout = () => {
    localStorage.removeItem(ACCESS_KEY);
    localStorage.removeItem(REFRESH_KEY);
    localStorage.removeItem(USER_KEY);
    apiSetAccessToken(null);
    setUser(null);
    setAccessToken(null);
    setRefreshToken(null);
  };

  const login = async (email: string, password: string) => {
    const res = await fetch(import.meta.env.VITE_API_URL + "/api/auth/login", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email, password }),
    });
    if (!res.ok) {
      const err = await res.json().catch(() => ({}));
      throw new Error(err?.detail || "No se pudo iniciar sesión");
    }
    const data = (await res.json()) as LoginResponse;
    localStorage.setItem(ACCESS_KEY, data.access_token);
    localStorage.setItem(REFRESH_KEY, data.refresh_token);
    localStorage.setItem(USER_KEY, JSON.stringify(data.user));
    apiSetAccessToken(data.access_token);
    setAccessToken(data.access_token);
    setRefreshToken(data.refresh_token);
    setUser(data.user);
  };

  const value = useMemo<AuthContextValue>(
    () => ({
      user,
      accessToken,
      refreshToken,
      isAuthenticated: Boolean(user && accessToken),
      loading,
      login,
      logout: doLogout,
    }),
    [user, accessToken, refreshToken, loading]
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};

export const useAuth = (): AuthContextValue => {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth debe usarse dentro de <AuthProvider>");
  return ctx;
};
