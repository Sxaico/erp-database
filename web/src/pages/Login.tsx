import React, { useState } from "react";
import { useLocation, useNavigate } from "react-router-dom";
import { useAuth } from "../auth/AuthContext";

export default function Login() {
  const { login } = useAuth();
  const nav = useNavigate();
  const location = useLocation() as any;
  const redirectTo = location.state?.from?.pathname || "/projects";

  const [email, setEmail] = useState("admin@miempresa.com");
  const [password, setPassword] = useState("admin123");
  const [loading, setLoading] = useState(false);
  const [err, setErr] = useState<string | null>(null);

  const onSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setErr(null);
    setLoading(true);
    try {
      await login(email, password);
      nav(redirectTo, { replace: true });
    } catch (ex: any) {
      setErr(ex?.message || "Error de autenticación");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ minHeight: "100dvh", display: "grid", placeItems: "center", fontFamily: "system-ui, sans-serif" }}>
      <form onSubmit={onSubmit} style={{ width: 320, display: "grid", gap: 12 }}>
        <h2>Iniciar sesión</h2>
        <label style={{ display: "grid", gap: 6 }}>
          <span>Email</span>
          <input
            autoFocus
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
            style={{ padding: 10, borderRadius: 8, border: "1px solid #ddd" }}
          />
        </label>
        <label style={{ display: "grid", gap: 6 }}>
          <span>Contraseña</span>
          <input
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
            style={{ padding: 10, borderRadius: 8, border: "1px solid #ddd" }}
          />
        </label>
        {err && <div style={{ color: "#b00" }}>{err}</div>}
        <button
          type="submit"
          disabled={loading}
          style={{
            padding: "10px 14px",
            borderRadius: 8,
            background: "#111827",
            color: "white",
            border: "none",
            cursor: "pointer",
          }}
        >
          {loading ? "Entrando…" : "Entrar"}
        </button>
        <div style={{ fontSize: 12, color: "#555" }}>
          Tip: usa <strong>admin@miempresa.com</strong> / <strong>admin123</strong>
        </div>
      </form>
    </div>
  );
}
