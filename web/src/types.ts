// web/src/types.ts
export type Rol = {
  id: number;
  nombre: string;
  descripcion?: string | null;
  activo: boolean;
  created_at: string;
};

export type DepartamentoSimple = {
  id: number;
  nombre: string;
  descripcion?: string | null;
};

export type Usuario = {
  id: number;
  uuid: string;
  email: string;
  nombre: string;
  apellido: string;
  nombre_completo: string;
  telefono?: string | null;
  activo: boolean;
  ultimo_login?: string | null;
  created_at: string;
  roles: Rol[];
  departamentos: DepartamentoSimple[];
};

export type LoginResponse = {
  access_token: string;
  refresh_token: string;
  token_type: "bearer";
  expires_in: number;
  user: Usuario;
};

export type Proyecto = {
  id: number;
  uuid: string;
  codigo?: string | null;
  nombre: string;
  estado: string;
  prioridad: number;
  avance_pct: number | null;
  presupuesto_monto: number | null;
};

export type Tarea = {
  id: number;
  uuid: string;
  proyecto_id: number;
  titulo: string;
  estado: "PENDIENTE" | "EN_PROGRESO" | "HECHA" | string;
  prioridad: number;
  real_horas: number | null;
};

export type ResumenEstadoItem = {
  proyecto_id: number;
  proyecto: string;
  estado: string;
  cantidad: number;
};
