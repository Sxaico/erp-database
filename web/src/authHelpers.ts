// src/auth.ts
import { api, tokenStore, User } from './api';

export type AuthState = {
  user: User | null;
  loading: boolean;
};

export async function doLogin(email: string, password: string): Promise<User> {
  const user = await api.login(email, password);
  return user;
}

export function doLogout() {
  tokenStore.clear();
  // Nada más: el AuthContext se encargará de limpiar el user en memoria
}

export function hasRole(user: User | null, roleName: string): boolean {
  if (!user) return false;
  return (user.roles || []).some(r => r.nombre === roleName);
}
