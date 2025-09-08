import React from "react";
import { Outlet } from "react-router-dom";

export default function SimpleLayout() {
  return (
    <div style={{ maxWidth: 960, margin: "0 auto", padding: 16 }}>
      <Outlet />
    </div>
  );
}
