// web/src/api/auth.ts
export type User = {
  id: number; email: string; nombre: string; apellido: string;
  roles?: { id:number; nombre:string }[];
};

const ACCESS_KEY = "access_token";
const REFRESH_KEY = "refresh_token";
const USER_KEY = "user";

export const setSession = (access: string, refresh: string, user?: User) => {
  localStorage.setItem(ACCESS_KEY, access);
  localStorage.setItem(REFRESH_KEY, refresh);
  if (user) localStorage.setItem(USER_KEY, JSON.stringify(user));
  window.dispatchEvent(new Event("storage")); // notificar a context
};

export const clearSession = () => {
  localStorage.removeItem(ACCESS_KEY);
  localStorage.removeItem(REFRESH_KEY);
  localStorage.removeItem(USER_KEY);
  window.dispatchEvent(new Event("storage"));
};

export const getAccessToken = () => localStorage.getItem(ACCESS_KEY) || "";
export const getRefreshToken = () => localStorage.getItem(REFRESH_KEY) || "";
export const getUser = (): User | null => {
  const raw = localStorage.getItem(USER_KEY);
  return raw ? JSON.parse(raw) as User : null;
};
