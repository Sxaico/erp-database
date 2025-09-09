// web/src/components/ProtectedRoute.tsx
import { Navigate, useLocation } from "react-router-dom";
import { isLoggedIn } from "../api";

export default function ProtectedRoute({ children }: { children: JSX.Element }) {
  const loc = useLocation();
  if (!isLoggedIn()) return <Navigate to="/login" replace state={{ from: loc }} />;
  return children;
}
