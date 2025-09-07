// web/src/pages/Login.tsx
import React, { useState } from "react";
import { useAuth } from "../auth/AuthContext";
import { useNavigate } from "react-router-dom";

const container: React.CSSProperties = {
  display: "grid",
  placeItems: "center",
  minHeight: "100vh",
  background: "#0f172a",
  color: "#e2e8f0",
  padding: "16px",
};
const card: React.CSSProperties = {
  width: "100%",
  maxWidth: 420,
  background: "#111827",
  borderRadius: 12,
  padding: 24,
  boxShadow: "0 10px 30px rgba(0,0,0,.3)",
  border: "1px solid #1f2937",
};
const input: React.CSSProperties = {
  width: "100%",
  padding: "10px 12px",
  background: "#0b1220",
  color: "#e5e7eb",
  border: "1px solid #1f2937",
  borderRadius: 8,
};
const btn: React.CSSProperties = {
  width: "100%",
  padding: "10px 12px",
  borderRadius: 8,
  border: "1px solid #334155",
  cursor: "pointer",
  background: "linear-gradient(90deg,#111827,#0b1220)",
  color: "#e2e8f0",
  fontWeight: 600,
};

export default function Login() {
  const { login, loggingIn } = useAuth();
  const nav = useNavigate();
  const [email, setEmail] = useState("admin@miempresa.com");
  const [password, setPassword] = useState("admin123");
  const [error, setError] = useState<string | null>(null);

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    try {
      await login(email, password);
      nav("/projects", { replace: true });
    } catch (err: any) {
      setError(err?.message || "Error de autenticación");
    }
  }

  return (
    <div style={container}>
      <form onSubmit={onSubmit} style={card}>
        <h1 style={{ fontSize: 22, marginBottom: 8 }}>ERP MVP</h1>
        <p style={{ opacity: 0.8, marginBottom: 16 }}>Iniciá sesión para continuar</p>
        {error && (
          <div style={{ marginBottom: 12, padding: 10, border: "1px solid #7f1d1d", background: "#1f2937", borderRadius: 8 }}>
            {error}
          </div>
        )}
        <div style={{ display: "grid", gap: 12 }}>
          <label>
            <div style={{ marginBottom: 6, fontSize: 13, opacity: 0.9 }}>Email</div>
            <input style={input} type="email" value={email} onChange={(e) => setEmail(e.target.value)} required />
          </label>
          <label>
            <div style={{ marginBottom: 6, fontSize: 13, opacity: 0.9 }}>Contraseña</div>
            <input style={input} type="password" value={password} onChange={(e) => setPassword(e.target.value)} required />
          </label>
          <button style={btn} type="submit" disabled={loggingIn}>
            {loggingIn ? "Ingresando..." : "Ingresar"}
          </button>
        </div>
        <div style={{ marginTop: 16, fontSize: 12, opacity: 0.7 }}>
          Tip: usá admin@miempresa.com / admin123
        </div>
      </form>
    </div>
  );
}
