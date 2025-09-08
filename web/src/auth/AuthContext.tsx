// web/src/auth/AuthContext.tsx
import React, { createContext, useContext, useEffect, useMemo, useState } from "react";

export type User = {
  id: number;
  email: string;
  nombre?: string;
  apellido?: string;
  nombre_completo?: string;
  roles?: { nombre: string }[];
};

type AuthContextType = {
  user: User | null;
  loading: boolean;
  isAuthenticated: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
  getAccessToken: () => Promise<string | null>;
};

const AuthContext = createContext<AuthContextType | null>(null);

const AT_KEY = "erp.at";
const RT_KEY = "erp.rt";
const API = import.meta.env.VITE_API_URL ?? "http://localhost:8000";

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [accessToken, setAccessToken] = useState<string | null>(localStorage.getItem(AT_KEY));
  const [refreshToken, setRefreshToken] = useState<string | null>(localStorage.getItem(RT_KEY));
  const [accessExp, setAccessExp] = useState<number | null>(null);
  const [loading, setLoading] = useState(true);

  const saveTokens = (at: string, rt?: string, expiresIn?: number) => {
    setAccessToken(at);
    localStorage.setItem(AT_KEY, at);
    if (rt) {
      setRefreshToken(rt);
      localStorage.setItem(RT_KEY, rt);
    }
    if (expiresIn) setAccessExp(Date.now() + expiresIn * 1000);
  };

  const fetchMe = async (token: string) => {
    const res = await fetch(`${API}/api/auth/me`, { headers: { Authorization: `Bearer ${token}` } });
    if (!res.ok) throw new Error("Token inválido");
    const u = (await res.json()) as User;
    setUser(u);
    return u;
  };

  const login = async (email: string, password: string) => {
    const res = await fetch(`${API}/api/auth/login`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email, password })
    });
    if (!res.ok) {
      const err = await res.json().catch(() => ({}));
      throw new Error(err?.detail || "Error de login");
    }
    const data = (await res.json()) as { access_token: string; refresh_token: string; expires_in: number; user: User };
    saveTokens(data.access_token, data.refresh_token, data.expires_in);
    await fetchMe(data.access_token);
  };

  const refresh = async (): Promise<string | null> => {
    if (!refreshToken) return null;
    const res = await fetch(`${API}/api/auth/refresh`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ refresh_token: refreshToken })
    });
    if (!res.ok) {
      logout();
      return null;
    }
    const data = (await res.json()) as { access_token: string; expires_in: number };
    saveTokens(data.access_token, undefined, data.expires_in);
    return data.access_token;
  };

  const getAccessToken = async () => {
    if (accessExp && accessExp - Date.now() < 60_000) {
      return await refresh();
    }
    return accessToken;
  };

  const logout = () => {
    localStorage.removeItem(AT_KEY);
    localStorage.removeItem(RT_KEY);
    setAccessToken(null);
    setRefreshToken(null);
    setAccessExp(null);
    setUser(null);
  };

  useEffect(() => {
    (async () => {
      try {
        const at = localStorage.getItem(AT_KEY);
        if (at) await fetchMe(at);
      } catch {
        logout();
      } finally {
        setLoading(false);
      }
    })();
  }, []);

  const value = useMemo<AuthContextType>(
    () => ({ user, loading, isAuthenticated: !!user, login, logout, getAccessToken }),
    [user, loading]
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};

export const useAuth = () => {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth debe usarse dentro de <AuthProvider>");
  return ctx;
};
