import { apiFetch } from "./client";

export type Role = { id: number; nombre: string; activo: boolean };
export type User = {
  id: number; email: string; nombre: string; apellido: string;
  roles: Role[];
};

export async function login(email: string, password: string) {
  return apiFetch("/api/auth/login", {
    method: "POST",
    body: JSON.stringify({ email, password }),
  }) as Promise<{ access_token: string; refresh_token: string; user: User }>;
}

export async function me() {
  return apiFetch("/api/auth/me") as Promise<User>;
}
