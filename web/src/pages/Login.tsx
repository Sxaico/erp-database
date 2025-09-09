// web/src/pages/Login.tsx
import { useState } from "react";
import { useNavigate, useLocation } from "react-router-dom";
import { login } from "../api";

export default function LoginPage() {
  const [email, setEmail] = useState("admin@miempresa.com");
  const [password, setPassword] = useState("admin123");
  const [loading, setLoading] = useState(false);
  const [err, setErr] = useState<string | null>(null);
  const nav = useNavigate();
  const loc = useLocation() as any;

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setErr(null); setLoading(true);
    try {
      await login(email, password);
      const to = loc?.state?.from?.pathname || "/projects";
      nav(to, { replace: true });
    } catch (e: any) {
      setErr(e?.message || "Error de autenticación");
    } finally {
      setLoading(false);
    }
  }

  return (
    <div style={{ maxWidth: 420, margin: "80px auto", display: "grid", gap: 12 }}>
      <h2>Ingresar</h2>
      <form onSubmit={onSubmit} style={{ display: "grid", gap: 8 }}>
        <input placeholder="Email" value={email} onChange={(e)=>setEmail(e.target.value)} />
        <input placeholder="Password" type="password" value={password} onChange={(e)=>setPassword(e.target.value)} />
        <button disabled={loading} type="submit">{loading ? "Ingresando…" : "Entrar"}</button>
        {err && <small style={{ color: "crimson" }}>{err}</small>}
      </form>
      <small>Tip: usá las cuentas seed del README.</small>
    </div>
  );
}
