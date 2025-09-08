import React, { createContext, useContext, useEffect, useState } from "react";

type User = {
  id: number;
  email: string;
  nombre?: string | null;
  apellido?: string | null;
};

type AuthContextValue = {
  token: string | null;
  user: User | null;
  setToken: (t: string | null) => void;
};

const AuthContext = createContext<AuthContextValue>({
  token: null,
  user: null,
  setToken: () => {},
});

const API_URL = import.meta.env.VITE_API_URL || "http://localhost:8000";

export const AuthProvider: React.FC<React.PropsWithChildren> = ({ children }) => {
  const [token, setToken] = useState<string | null>(
    typeof window !== "undefined" ? localStorage.getItem("access_token") : null
  );
  const [user, setUser] = useState<User | null>(null);

  useEffect(() => {
    if (!token) {
      setUser(null);
      return;
    }
    (async () => {
      try {
        const res = await fetch(`${API_URL}/api/auth/me`, {
          headers: { Authorization: `Bearer ${token}` },
        });
        if (!res.ok) throw new Error("me failed");
        const data = await res.json();
        setUser(data);
      } catch {
        setUser(null);
      }
    })();
  }, [token]);

  // Mantener token en localStorage si alguien lo setea manualmente más adelante
  useEffect(() => {
    if (typeof window === "undefined") return;
    if (token) localStorage.setItem("access_token", token);
    else localStorage.removeItem("access_token");
  }, [token]);

  return (
    <AuthContext.Provider value={{ token, user, setToken }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => useContext(AuthContext);
