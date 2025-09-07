import { ReactNode, useEffect, useState } from "react";
import { Navigate } from "react-router-dom";
import { isAuthenticated, getAccessToken } from "../authHelpers";
import { apiFetch } from "../api";

export default function ProtectedRoute({ children }: { children: ReactNode }) {
  const [ok, setOk] = useState<boolean | null>(null);

  useEffect(() => {
    // Intento suave: si no hay access token, pero hay refresh, el primer fetch gatilla refresh.
    async function ping() {
      try {
        const r = await apiFetch("/health");
        setOk(r.ok);
      } catch {
        setOk(false);
      }
    }
    if (!getAccessToken() && isAuthenticated()) ping();
    else setOk(isAuthenticated());
  }, []);

  if (ok === null) return null; // loader simple; para MVP no pintamos spinner
  if (!ok) return <Navigate to="/login" replace />;
  return <>{children}</>;
}
