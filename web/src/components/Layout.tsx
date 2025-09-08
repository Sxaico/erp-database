import React from "react";
import { Link, useNavigate } from "react-router-dom";
import { useAuth } from "../auth/AuthContext";

export default function Layout({ children }: { children: React.ReactNode }) {
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  const onLogout = () => {
    logout();
    navigate("/login");
  };

  return (
    <div style={{ fontFamily: "system-ui, sans-serif", minHeight: "100vh", background: "#f6f7f9" }}>
      <header style={{ background: "#0f172a", color: "white", padding: "12px 16px", display: "flex", gap: 16, alignItems: "center" }}>
        <strong>ERP MVP</strong>
        <nav style={{ display: "flex", gap: 12 }}>
          <Link to="/" style={{ color: "white" }}>Inicio</Link>
          <Link to="/projects" style={{ color: "white" }}>Proyectos</Link>
        </nav>
        <div style={{ marginLeft: "auto", display: "flex", gap: 12, alignItems: "center" }}>
          {user && <span style={{ opacity: 0.8 }}>Hola, {user.nombre}</span>}
          <button onClick={onLogout} style={{ background: "transparent", border: "1px solid #94a3b8", color: "white", padding: "4px 10px", borderRadius: 6, cursor: "pointer" }}>
            Salir
          </button>
        </div>
      </header>
      <main style={{ maxWidth: 1100, margin: "20px auto", padding: "0 16px" }}>
        {children}
      </main>
    </div>
  );
}
