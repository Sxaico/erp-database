// src/components/Navbar.tsx
import React from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../auth/AuthContext';

export default function Navbar() {
  const { user, logout } = useAuth();
  return (
    <nav style={{display:'flex',gap:12,padding:12,borderBottom:'1px solid #e5e5e5'}}>
      <Link to="/">Home</Link>
      <Link to="/projects">Projects</Link>
      <div style={{marginLeft:'auto'}} />
      {user ? (
        <>
          <span style={{opacity:.7}}>{user.nombre} {user.apellido}</span>
          <button onClick={logout} style={{marginLeft:12}}>Salir</button>
        </>
      ) : (
        <Link to="/login">Login</Link>
      )}
    </nav>
  );
}
