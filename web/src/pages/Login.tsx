// web/src/pages/Login.tsx
import React, { useState } from "react";
import { useAuth } from "../auth/AuthContext";
import { useNavigate, useLocation } from "react-router-dom";

export default function Login() {
  const { login } = useAuth();
  const nav = useNavigate();
  const loc = useLocation() as any;
  const [email, setEmail] = useState("admin@miempresa.com");
  const [password, setPassword] = useState("admin123");
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  const onSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setBusy(true); setError(null);
    try {
      await login(email, password);
      nav(loc?.state?.from?.pathname || "/projects", { replace: true });
    } catch (err: any) {
      setError("Credenciales inválidas");
    } finally {
      setBusy(false);
    }
  };

  return (
    <div style={{maxWidth:360, margin:"64px auto", padding:24, border:"1px solid #eee", borderRadius:12}}>
      <h2 style={{marginBottom:8}}>Iniciar sesión</h2>
      <form onSubmit={onSubmit}>
        <label>Email</label>
        <input value={email} onChange={e=>setEmail(e.target.value)} type="email" required style={{width:"100%", padding:8, marginBottom:12}}/>
        <label>Password</label>
        <input value={password} onChange={e=>setPassword(e.target.value)} type="password" required style={{width:"100%", padding:8, marginBottom:12}}/>
        <button disabled={busy} style={{width:"100%", padding:10}}>{busy? "Ingresando..." : "Ingresar"}</button>
        {error && <p style={{color:"tomato"}}>{error}</p>}
      </form>
      <p style={{fontSize:12, opacity:.7, marginTop:12}}>
        Demo: admin@miempresa.com / admin123
      </p>
    </div>
  );
}
