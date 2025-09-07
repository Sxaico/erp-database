// src/context/AuthContext.tsx
import React, { createContext, useContext, useEffect, useState } from 'react';
import { api, tokenStore, User } from '../api';
import { doLogout } from '../authHelpers';

type Ctx = {
  user: User | null;
  setUser: (u: User | null) => void;
  loading: boolean;
  logout: () => void;
};

const AuthContext = createContext<Ctx>({
  user: null, setUser: () => {}, loading: true, logout: () => {}
});

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let alive = true;
    async function boot() {
      try {
        if (tokenStore.access) {
          const me = await api.me();
          if (!alive) return;
          setUser(me);
        }
      } catch (_) {
        // token inválido → limpiar
        doLogout();
        setUser(null);
      } finally {
        if (alive) setLoading(false);
      }
    }
    boot();
    return () => { alive = false; };
  }, []);

  const logout = () => {
    doLogout();
    setUser(null);
  };

  return (
    <AuthContext.Provider value={{ user, setUser, loading, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() { return useContext(AuthContext); }
