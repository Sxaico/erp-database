// web/src/App.tsx
import React from "react";
import { Link, Outlet } from "react-router-dom";
import { useAuth } from "./auth/AuthContext";

export default function App() {
  const { user, logout } = useAuth();
  return (
    <div>
      <header style={{display:"flex", alignItems:"center", justifyContent:"space-between", padding:"12px 16px", borderBottom:"1px solid #eee"}}>
        <div style={{display:"flex", gap:12, alignItems:"center"}}>
          <strong>ERP MVP</strong>
          <Link to="/projects">Proyectos</Link>
        </div>
        <div>
          {user ? (
            <>
              <span style={{marginRight:12, opacity:.8}}>
                {user.nombre} {user.apellido}
              </span>
              <button onClick={logout}>Salir</button>
            </>
          ) : <Link to="/login">Ingresar</Link>}
        </div>
      </header>
      <Outlet />
    </div>
  );
}
