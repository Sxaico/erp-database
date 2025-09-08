import React from "react";
import { Route, Routes } from "react-router-dom";
import ProtectedRoute from "./components/ProtectedRoute";
import Layout from "./components/Layout";

import Home from "./pages/Home";
import Login from "./pages/Login";
import Projects from "./pages/Projects";
import ProjectDetail from "./pages/ProjectDetail";
import Report from "./pages/Report";

export default function App() {
  return (
    <Routes>
      <Route path="/login" element={<Login />} />

      <Route element={<ProtectedRoute />}>
        <Route
          element={
            <Layout>
              <Home />
            </Layout>
          }
          path="/"
        />
        <Route
          element={
            <Layout>
              <Projects />
            </Layout>
          }
          path="/projects"
        />
        <Route
          element={
            <Layout>
              <ProjectDetail />
            </Layout>
          }
          path="/projects/:id"
        />
        <Route
          element={
            <Layout>
              <Report />
            </Layout>
          }
          path="/projects/:id/report"
        />
      </Route>

      <Route path="*" element={<div style={{ padding: 24 }}>404</div>} />
    </Routes>
  );
}
