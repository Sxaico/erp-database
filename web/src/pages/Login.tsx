// src/pages/Login.tsx
import React, { useState } from 'react';
import { doLogin } from '../authHelpers';
import { useAuth } from '../auth/AuthContext';
import { useNavigate } from 'react-router-dom';

export default function Login() {
  const nav = useNavigate();
  const { setUser } = useAuth();
  const [email, setEmail] = useState('admin@miempresa.com');
  const [password, setPassword] = useState('admin123');
  const [loading, setLoading] = useState(false);
  const [err, setErr] = useState<string | null>(null);

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setErr(null);
    setLoading(true);
    try {
      const u = await doLogin(email, password);
      setUser(u);
      nav('/projects');
    } catch (e: any) {
      setErr(e?.message || 'Error de login');
    } finally {
      setLoading(false);
    }
  }

  return (
    <div style={{padding:16, maxWidth:380}}>
      <h2>Login</h2>
      <form onSubmit={onSubmit} style={{display:'grid', gap:8}}>
        <label>Email
          <input value={email} onChange={e=>setEmail(e.target.value)} required />
        </label>
        <label>Password
          <input type="password" value={password} onChange={e=>setPassword(e.target.value)} required />
        </label>
        <button type="submit" disabled={loading}>{loading ? 'Ingresando...' : 'Ingresar'}</button>
        {err && <div style={{color:'crimson'}}>{err}</div>}
      </form>
      <div style={{marginTop:12, fontSize:12, opacity:.75}}>
        Tip: podés probar también <code>colab1@miempresa.com / user123</code>
      </div>
    </div>
  );
}
