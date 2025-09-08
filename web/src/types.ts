export type Project = {
  id: number;
  uuid: string;
  codigo: string | null;
  nombre: string;
  estado: string;
  prioridad: number;
  avance_pct: number;
  presupuesto_monto: number;
};

export type Task = {
  id: number;
  proyecto_id: number;
  titulo: string;
  descripcion?: string | null;
  estado: "PENDIENTE" | "EN_PROGRESO" | "BLOQUEADA" | "HECHA";
  prioridad: number;
};

export type ResumenEstadoItem = {
  proyecto_id: number;
  proyecto: string;
  estado: string;
  cantidad: number;
};
