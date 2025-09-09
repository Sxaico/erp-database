// web/src/pages/Login.tsx
import { FormEvent, useState } from "react";
import { login, isAuthenticated } from "../api";
import { useNavigate, Navigate } from "react-router-dom";

export default function LoginPage() {
  const nav = useNavigate();
  const [email, setEmail] = useState("admin@miempresa.com");
  const [password, setPassword] = useState("admin123");
  const [error, setError] = useState<string | null>(null);
  if (isAuthenticated()) return <Navigate to="/projects" replace />;

  const onSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setError(null);
    try {
      await login(email, password);
      nav("/projects");
    } catch (err: any) {
      setError(err?.message || "Error de login");
    }
  };

  return (
    <div style={{maxWidth:400, margin:"48px auto"}}>
      <h2>Ingresar</h2>
      <form onSubmit={onSubmit} style={{display:"grid", gap:8}}>
        <input value={email} onChange={e=>setEmail(e.target.value)} placeholder="Email" />
        <input value={password} onChange={e=>setPassword(e.target.value)} type="password" placeholder="Password" />
        <button type="submit">Entrar</button>
      </form>
      {error && <p style={{color:"crimson"}}>{error}</p>}
      <p style={{opacity:.7, marginTop:8}}>Tip: admin@miempresa.com / admin123</p>
    </div>
  );
}
