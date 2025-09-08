import React, { useState } from "react";
import { useAuth } from "../auth/AuthContext";
import { useNavigate, Navigate } from "react-router-dom";

export default function LoginPage() {
  const { isAuthenticated, login } = useAuth();
  const navigate = useNavigate();

  const [email, setEmail] = useState("admin@miempresa.com");
  const [password, setPassword] = useState("admin123");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  if (isAuthenticated) return <Navigate to="/projects" replace />;

  const onSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError(null);
    try {
      await login(email, password);
      navigate("/projects", { replace: true });
    } catch (err: any) {
      setError(err?.message || "Error al iniciar sesión");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ maxWidth: 380, margin: "64px auto", padding: 24, border: "1px solid #eee", borderRadius: 12 }}>
      <h1 style={{ marginBottom: 8 }}>Ingresar</h1>
      <p style={{ color: "#666", marginTop: 0, marginBottom: 16 }}>
        Usa las credenciales seed del README.
      </p>

      {error && (
        <div style={{ background: "#fee", color: "#900", padding: "8px 12px", borderRadius: 8, marginBottom: 12 }}>
          {error}
        </div>
      )}

      <form onSubmit={onSubmit}>
        <div style={{ display: "grid", gap: 12 }}>
          <label>
            <div style={{ fontSize: 12, color: "#555" }}>Email</div>
            <input
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              type="email"
              required
              style={{ width: "100%", padding: 10, borderRadius: 8, border: "1px solid #ccc" }}
            />
          </label>
          <label>
            <div style={{ fontSize: 12, color: "#555" }}>Password</div>
            <input
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              type="password"
              required
              style={{ width: "100%", padding: 10, borderRadius: 8, border: "1px solid #ccc" }}
            />
          </label>
          <button
            type="submit"
            disabled={loading}
            style={{
              padding: "10px 14px",
              borderRadius: 8,
              border: "1px solid #333",
              background: loading ? "#ddd" : "#111",
              color: "#fff",
              cursor: loading ? "default" : "pointer"
            }}
          >
            {loading ? "Entrando..." : "Entrar"}
          </button>
        </div>
      </form>
    </div>
  );
}
