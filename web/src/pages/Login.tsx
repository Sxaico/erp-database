import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../auth/AuthContext";

export default function Login() {
  const { login } = useAuth();
  const navigate = useNavigate();
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
      navigate("/");
    } catch (e: any) {
      setErr(e?.message || "Error");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ maxWidth: 420, margin: "80px auto", padding: 24, background: "white", borderRadius: 12, boxShadow: "0 6px 24px rgba(0,0,0,.08)" }}>
      <h2 style={{ marginTop: 0 }}>Iniciar sesión</h2>
      <form onSubmit={onSubmit} style={{ display: "grid", gap: 12 }}>
        <label>
          Email
          <input value={email} onChange={e=>setEmail(e.target.value)} type="email" placeholder="tu@empresa.com"
                 style={{ width: "100%", padding: 10, borderRadius: 8, border: "1px solid #cbd5e1" }} />
        </label>
        <label>
          Password
          <input value={password} onChange={e=>setPassword(e.target.value)} type="password" placeholder="••••••••"
                 style={{ width: "100%", padding: 10, borderRadius: 8, border: "1px solid #cbd5e1" }} />
        </label>
        {err && <div style={{ color: "#b91c1c" }}>{err}</div>}
        <button disabled={loading} type="submit" style={{ padding: "10px 14px", borderRadius: 8, background: "#0f172a", color: "white", border: "none", cursor: "pointer" }}>
          {loading ? "Ingresando..." : "Ingresar"}
        </button>
      </form>
    </div>
  );
}
  