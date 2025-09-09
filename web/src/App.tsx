// web/src/App.tsx
import { Routes, Route, Navigate, Link, useNavigate } from "react-router-dom";
import LoginPage from "./pages/Login";
import ProjectsPage from "./pages/Projects";
import ProjectDetailPage from "./pages/ProjectDetail";
import { isAuthenticated, logout } from "./api";

function Nav() {
  const nav = useNavigate();
  return (
    <nav style={{display:"flex", gap:12, padding:12, borderBottom:"1px solid #eee"}}>
      <Link to="/projects">Proyectos</Link>
      <div style={{flex:1}} />
      {isAuthenticated() ? (
        <button onClick={() => { logout(); nav("/login"); }}>Salir</button>
      ) : <Link to="/login">Login</Link>}
    </nav>
  );
}

function Protected({ children }: { children: React.ReactNode }) {
  if (!isAuthenticated()) return <Navigate to="/login" replace />;
  return <>{children}</>;
}

export default function App() {
  return (
    <>
      <Nav />
      <Routes>
        <Route path="/login" element={<LoginPage />} />
        <Route path="/projects" element={<Protected><ProjectsPage /></Protected>} />
        <Route path="/projects/:id" element={<Protected><ProjectDetailPage /></Protected>} />
        <Route path="*" element={<Navigate to={isAuthenticated()?"/projects":"/login"} replace />} />
      </Routes>
    </>
  );
}
