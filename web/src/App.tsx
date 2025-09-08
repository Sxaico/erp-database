import React from "react";
import { Link, NavLink, Outlet, Route, Routes } from "react-router-dom";
import Home from "./pages/Home";
import Login from "./pages/Login";
import Projects from "./pages/Projects";
import ProtectedRoute from "./components/ProtectedRoute";
import { useAuth } from "./auth/AuthContext";

function Shell() {
  const { user, logout } = useAuth();
  return (
    <div style={{ fontFamily: "system-ui, sans-serif" }}>
      <header style={{ display: "flex", alignItems: "center", justifyContent: "space-between", padding: "10px 16px", borderBottom: "1px solid #eee" }}>
        <Link to="/" style={{ fontWeight: 700, textDecoration: "none", color: "#111827" }}>ERP MVP</Link>
        <nav style={{ display: "flex", gap: 12 }}>
          <NavLink to="/" style={({ isActive }) => ({ color: isActive ? "#111827" : "#6b7280", textDecoration: "none" })}>Home</NavLink>
          <NavLink to="/projects" style={({ isActive }) => ({ color: isActive ? "#111827" : "#6b7280", textDecoration: "none" })}>Proyectos</NavLink>
        </nav>
        <div>
          {user ? (
            <div style={{ display: "flex", gap: 8, alignItems: "center" }}>
              <span style={{ fontSize: 14, color: "#374151" }}>{user.nombre} {user.apellido}</span>
              <button onClick={logout} style={{ padding: "6px 10px", borderRadius: 8, border: "1px solid #ddd", background: "white", cursor: "pointer" }}>
                Salir
              </button>
            </div>
          ) : (
            <NavLink to="/login" style={{ textDecoration: "none", color: "#111827" }}>Iniciar sesión</NavLink>
          )}
        </div>
      </header>
      <Outlet />
    </div>
  );
}

export default function App() {
  return (
    <Routes>
      <Route element={<Shell />}>
        <Route index element={<Home />} />
        <Route path="/login" element={<Login />} />
        <Route
          path="/projects"
          element={
            <ProtectedRoute>
              <Projects />
            </ProtectedRoute>
          }
        />
        <Route path="*" element={<div style={{ padding: 24 }}>404</div>} />
      </Route>
    </Routes>
  );
}
