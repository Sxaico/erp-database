// web/src/auth/AuthContext.tsx
import React, { createContext, useContext, useEffect, useMemo, useState } from "react";
import { api } from "../api/client";
import { clearSession, getUser, setSession, type User } from "../api/auth";

type AuthState = { user: User | null; loading: boolean; };
type AuthCtx = AuthState & {
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
};
const Ctx = createContext<AuthCtx>({ user: null, loading: true, login: async ()=>{}, logout: ()=>{} });

export const AuthProvider: React.FC<{children: React.ReactNode}> = ({ children }) => {
  const [user, setUser] = useState<User | null>(getUser());
  const [loading, setLoading] = useState<boolean>(false);

  useEffect(() => {
    const onStorage = () => setUser(getUser());
    window.addEventListener("storage", onStorage);
    return () => window.removeEventListener("storage", onStorage);
  }, []);

  const login = async (email: string, password: string) => {
    setLoading(true);
    try {
      const data = await api.post<{access_token:string; refresh_token:string; user:User}>("/api/auth/login", { email, password });
      setSession(data.access_token, data.refresh_token, data.user);
      setUser(data.user);
    } finally {
      setLoading(false);
    }
  };

  const logout = () => {
    clearSession();
    setUser(null);
  };

  const value = useMemo(() => ({ user, loading, login, logout }), [user, loading]);
  return <Ctx.Provider value={value}>{children}</Ctx.Provider>;
};

export const useAuth = () => useContext(Ctx);
