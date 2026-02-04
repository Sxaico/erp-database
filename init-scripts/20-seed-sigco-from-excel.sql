BEGIN;
SET client_encoding = 'UTF8';
SET search_path TO sigco, public;

-- CAT_AREAS_FRENTES
INSERT INTO sigco.cat_areas_frentes (area_codigo, area_nombre, descripcion, activo) VALUES
('A-GRAL', 'General Obra', 'Oficinas, Obrador, Campamento', TRUE),
('A-SILOS', 'Silos Carbonato', 'Áreas 200 y 300 (Altura) - MOC 7442/7928', TRUE),
('A-QUEM', 'Tren de Gas', 'Sector Quemadores (Zona Clasificada/Ex) - MOC 7951', TRUE),
('A-SHRIV', 'Shriver Piso 2', 'Edificio Filtro Prensa - Iluminación', TRUE),
('A-TK1048', 'Tanque 1048', 'Ingreso Tanque (Andamio req) - MOC 7996', TRUE),
('A-FILT', 'Filtros OTG', 'Salida Filtros (Debajo estructura) - MOC 7379', TRUE)
ON CONFLICT (area_codigo) DO UPDATE SET area_nombre=EXCLUDED.area_nombre, descripcion=EXCLUDED.descripcion, activo=EXCLUDED.activo;

-- CAT_ETAPAS
INSERT INTO sigco.cat_etapas (etapa_id, etapa_nombre, etapa_definicion, orden, activo) VALUES
('O1', 'Preparación', 'Frente habilitado, recursos movilizados, trabajo iniciado.', 1, TRUE),
('O2', 'Ejecución parcial', 'Producción parcial verificable y medible.', 2, TRUE),
('O3', 'Instalado', 'Elemento instalado físicamente sin terminación completa.', 3, TRUE),
('O4', 'Terminación operativa (pre-conexión)', 'Listo para conectar/continuar; montaje completo y extremos preparados.', 4, TRUE),
('O5', 'Conexión del activo', 'Landing/torque final en activo (se mide en el ítem del activo).', 5, TRUE),
('O6', 'Cierre operativo', 'Cierre del ítem desde perspectiva operativa (ajustes finales y liberación).', 6, TRUE)
ON CONFLICT (etapa_id) DO UPDATE SET etapa_nombre=EXCLUDED.etapa_nombre, etapa_definicion=EXCLUDED.etapa_definicion, orden=EXCLUDED.orden, activo=EXCLUDED.activo;

-- CAT_UNIDADES
INSERT INTO sigco.cat_unidades (unidad_id, unidad_tipo, uso_tipico, activo) VALUES
('m', 'Lineal', 'bandejas, caños, cables, cobre desnudo', TRUE),
('u', 'Unitario', 'equipos, instrumentos, luminarias, tableros', TRUE),
('kg', 'Peso', 'soportes/estructuras cuando se mide por peso', TRUE),
('juego', 'Conjunto', 'kits, conjuntos de accesorios', TRUE),
('lote', 'Agrupado', 'solo si no hay alternativa más controlable', TRUE),
('glb', 'Agrupado', 'global', TRUE)
ON CONFLICT (unidad_id) DO UPDATE SET unidad_tipo=EXCLUDED.unidad_tipo, uso_tipico=EXCLUDED.uso_tipico, activo=EXCLUDED.activo;

-- CAT_FAMILIAS (desde hoja CAT_FAMILIAS)
INSERT INTO sigco.cat_familias (familia_id, familia_nombre, alcance_tecnico) VALUES
('GEN', 'General', 'Actividades de apoyo, logística general o ítems no tipificados en las familias especialistas.'),
('CBL', 'Cables', 'Conductores eléctricos de potencia, control y datos.'),
('TRY', 'Trays', 'Sistemas de canalización abierta para cables.'),
('PIP', 'Pipes', 'Canalizaciones cerradas (Conduit) y tuberías.'),
('PNL', 'Panels', 'Tableros, centros de control y cajas de potencia.'),
('EQP', 'Equipment', 'Activos eléctricos de gran porte o específicos.'),
('INS', 'Instrumentation', 'Dispositivos de medición y control de señales.'),
('LGT', 'Lighting', 'Sistemas y artefactos de iluminación industrial.')
ON CONFLICT (familia_id) DO UPDATE SET familia_nombre=EXCLUDED.familia_nombre, alcance_tecnico=EXCLUDED.alcance_tecnico;

-- CAT_FAMILIAS (stubs) para familias que aparecen en BOQ_CONTROL pero no están en CAT_FAMILIAS
INSERT INTO sigco.cat_familias (familia_id, familia_nombre, alcance_tecnico) VALUES
('CON', 'CON', 'Pendiente (creado automáticamente porque aparece en BOQ_CONTROL)'),
('ELEC', 'ELEC', 'Pendiente (creado automáticamente porque aparece en BOQ_CONTROL)'),
('ING', 'ING', 'Pendiente (creado automáticamente porque aparece en BOQ_CONTROL)'),
('INST', 'INST', 'Pendiente (creado automáticamente porque aparece en BOQ_CONTROL)'),
('MEC', 'MEC', 'Pendiente (creado automáticamente porque aparece en BOQ_CONTROL)'),
('PAT', 'PAT', 'Pendiente (creado automáticamente porque aparece en BOQ_CONTROL)'),
('SPT', 'SPT', 'Pendiente (creado automáticamente porque aparece en BOQ_CONTROL)'),
('TER', 'TER', 'Pendiente (creado automáticamente porque aparece en BOQ_CONTROL)')
ON CONFLICT (familia_id) DO NOTHING;

-- CAT_RESTRICCIONES
INSERT INTO sigco.cat_restricciones (restriccion_id, categoria, restriccion_nombre, restriccion_definicion, activo) VALUES
('R01', 'Materiales', 'Faltante de materiales', 'Faltante / entrega incompleta / insumos no disponibles.', TRUE),
('R02', 'Ingeniería', 'Documentación/IFC', 'Planos IFC pendientes / cambios no definidos / RFIs.', TRUE),
('R03', 'Interfases', 'Interfases / liberaciones', 'Bloqueo por otra disciplina / área no liberada.', TRUE),
('R04', 'Equipo', 'Equipo fuera de servicio', 'Falla de plataforma / vehículo / herramienta crítica.', TRUE),
('R05', 'HSE', 'Permisos/Seguridad', 'Detención por permisos / seguridad / incidentes.', TRUE),
('R06', 'Clima', 'Clima', 'Viento/lluvia/nieve impide trabajo.', TRUE),
('R07', 'Logística', 'Logística interna', 'Accesos/traslados/caminos/abastecimiento interno.', TRUE),
('R08', 'Personal', 'Personal', 'Ausentismo/rotación/permisos/falta de dotación.', TRUE)
ON CONFLICT (restriccion_id) DO UPDATE SET categoria=EXCLUDED.categoria, restriccion_nombre=EXCLUDED.restriccion_nombre, restriccion_definicion=EXCLUDED.restriccion_definicion, activo=EXCLUDED.activo;

-- CAT_CATEGORIAS_PERSONAL
INSERT INTO sigco.cat_categorias_personal (categoria_id, categoria_nombre, tipo, descripcion, activo) VALUES
('IND-JO', 'Jefe de obra', 'Indirecto', 'Responsable general de ejecución en obra.', TRUE),
('IND-SUP', 'Supervisor', 'Indirecto', 'Supervisor de frente / coordinación diaria.', TRUE),
('IND-OT', 'Oficina técnica', 'Indirecto', 'Soporte técnico/planos/materiales.', TRUE),
('IND-CAL', 'Calidad', 'Indirecto', 'QA/QC / protocolos y liberaciones.', TRUE),
('IND-HYS', 'Higiene y Seguridad', 'Indirecto', 'Permisos, inspecciones, gestión HSE.', TRUE),
('DIR-OE', 'Oficial especializado', 'Directo', 'Oficial especializado / líder operativo.', TRUE),
('DIR-OF', 'Oficial', 'Directo', 'Oficial.', TRUE),
('DIR-MO', 'Medio oficial', 'Directo', 'Medio oficial.', TRUE),
('DIR-AY', 'Ayudante', 'Directo', 'Ayudante.', TRUE)
ON CONFLICT (categoria_id) DO UPDATE SET categoria_nombre=EXCLUDED.categoria_nombre, tipo=EXCLUDED.tipo, descripcion=EXCLUDED.descripcion, activo=EXCLUDED.activo;

-- CAT_EQUIPOS
INSERT INTO sigco.cat_equipos (equipo_id, equipo_nombre, equipo_tipo, activo) VALUES
('JLG450AJ', 'Plataforma Articulada JLG 450AJ', 'Plataforma Elevadora', TRUE),
('JLG600AJ', 'Plataforma Articulada JLG 600AJ', 'Plataforma Elevadora', TRUE),
('Camioneta1', 'Camioneta 1', 'Camioneta', TRUE),
('Camioneta2', 'Camioneta 2', 'Camioneta', TRUE),
('ATEGO', 'Camion Hidrogrúa', 'Camioneta', TRUE),
('Camioneta3', 'Camioneta 3', 'Hidrogrúa', TRUE)
ON CONFLICT (equipo_id) DO UPDATE SET equipo_nombre=EXCLUDED.equipo_nombre, equipo_tipo=EXCLUDED.equipo_tipo, activo=EXCLUDED.activo;

-- WBS
INSERT INTO sigco.wbs (wbs_id, wbs_nombre, wbs_descripcion, wbs_padre_id, nivel, activo) VALUES
('WBS-000', 'Proyecto General', 'Nodo Raíz', NULL, 0, TRUE),
('WBS-100', 'MOC 7442/7928', 'Sensores de Silos', 'WBS-000', 1, TRUE),
('WBS-200', 'MOC 7951', 'Sensor de Gas (Tren Quemador)', 'WBS-000', 1, TRUE),
('WBS-300', 'Iluminación', 'Mejora Iluminación Shriver', 'WBS-000', 1, TRUE),
('WBS-400', 'MOC 7996', 'Ingreso TK1048', 'WBS-000', 1, TRUE),
('WBS-500', 'MOC 7379', 'Salida Filtros OTG', 'WBS-000', 1, TRUE)
ON CONFLICT (wbs_id) DO UPDATE SET wbs_nombre=EXCLUDED.wbs_nombre, wbs_descripcion=EXCLUDED.wbs_descripcion, wbs_padre_id=EXCLUDED.wbs_padre_id, nivel=EXCLUDED.nivel, activo=EXCLUDED.activo;

-- BOQ_CONTROL
INSERT INTO sigco.boq_control (control_item_id, wbs_id, item_descripcion, familia_id, unidad_id, cantidad_base, area_codigo, activo) VALUES
('IN-GEN-01', 'WBS-000', 'Movilización y Logística inicial', 'GEN', 'glb', 1, 'A-GRAL', TRUE),
('IN-GEN-02', 'WBS-000', 'Desmovilización', 'GEN', 'glb', 1, 'A-GRAL', TRUE),
('IN-100-01', 'WBS-100', 'Soldadura/Pintura soportes conduits 3/4" y 1"', 'SPT', 'u', 100, 'A-SILOS', TRUE),
('IN-100-02', 'WBS-100', 'Montaje de soportes (fijación)', 'SPT', 'u', 100, 'A-SILOS', TRUE),
('IN-100-03', 'WBS-100', 'Canalización conduit 3/4" y 1"', 'CON', 'm', 55, 'A-SILOS', TRUE),
('IN-100-04', 'WBS-100', 'Tendido conductores de control', 'CBL', 'm', 520, 'A-SILOS', TRUE),
('IN-100-05', 'WBS-100', 'Soldadura y montaje pedestal transmisor', 'SPT', 'u', 4, 'A-SILOS', TRUE),
('IN-100-06', 'WBS-100', 'Megado, continuidad, tagueado y conexionado', 'TER', 'u', 12, 'A-SILOS', TRUE),
('IN-100-07', 'WBS-100', 'Montaje electroválvulas y filtros', 'INST', 'u', 8, 'A-SILOS', TRUE),
('IN-100-08', 'WBS-100', 'Montaje Tie-in y racor', 'MEC', 'm', 4, 'A-SILOS', TRUE),
('IN-100-09', 'WBS-100', 'Montaje tubing 10mm y conexionado', 'INST', 'm', 20, 'A-SILOS', TRUE),
('IN-100-10', 'WBS-100', 'Aterrado con v/a 6mm', 'PAT', 'm', 320, 'A-SILOS', TRUE),
('IN-200-01', 'WBS-200', 'Montaje conduits 2" (Zona Clasificada)', 'CON', 'm', 30, 'A-QUEM', TRUE),
('IN-200-02', 'WBS-200', 'Montaje materiales APEX', 'INST', 'u', 4, 'A-QUEM', TRUE),
('IN-200-03', 'WBS-200', 'Montaje luminarias APEX', 'ELEC', 'u', 4, 'A-QUEM', TRUE),
('IN-200-04', 'WBS-200', 'Tendido conductores y conexión luminarias', 'CBL', 'm', 50, 'A-QUEM', TRUE),
('IN-200-05', 'WBS-200', 'Soldadura y montaje soporte para sensor', 'SPT', 'm', 1, 'A-QUEM', TRUE),
('IN-200-06', 'WBS-200', 'Canalización conduit 3/4" APEX', 'CON', 'm', 40, 'A-QUEM', TRUE),
('IN-200-07', 'WBS-200', 'Tendido cable sensor hacia RIO', 'CBL', 'm', 50, 'A-QUEM', TRUE),
('IN-200-08', 'WBS-200', 'Megado, continuidad, tagueado y conexionado', 'TER', 'u', 6, 'A-QUEM', TRUE),
('IN-200-09', 'WBS-200', 'Aterrado con v/a 6mm (Quemador)', 'PAT', 'm', 50, 'A-QUEM', TRUE),
('IN-300-01', 'WBS-300', 'Informe de distribución de lúmenes', 'ING', 'glb', 1, 'A-SHRIV', TRUE),
('IN-300-02', 'WBS-300', 'Canalización 2" y artefactos de iluminación', 'CON', 'm', 20, 'A-SHRIV', TRUE),
('IN-300-03', 'WBS-300', 'Montaje JB para distribución de circuitos', 'ELEC', 'u', 2, 'A-SHRIV', TRUE),
('IN-300-04', 'WBS-300', 'Canalización conduit 3/4"', 'CON', 'm', 80, 'A-SHRIV', TRUE),
('IN-300-05', 'WBS-300', 'Tendido cable desde artefacto a caja JB', 'CBL', 'u', 60, 'A-SHRIV', TRUE),
('IN-300-06', 'WBS-300', 'Tendido cable troncal desde JB a tablero LP', 'CBL', 'u', 150, 'A-SHRIV', TRUE),
('IN-300-07', 'WBS-300', 'Megado, continuidad, tagueado y conexionado', 'TER', 'u', 8, 'A-SHRIV', TRUE),
('IN-300-08', 'WBS-300', 'Aterrado con v/a 6mm (Shriver)', 'PAT', 'm', 65, 'A-SHRIV', TRUE),
('IN-400-01', 'WBS-400', 'Soldadura y montaje soporte conduit 1" y 3/4"', 'SPT', 'u', 20, 'A-TK1048', TRUE),
('IN-400-02', 'WBS-400', 'Soldadura y montaje soporte pedestal Tx', 'SPT', 'u', 2, 'A-TK1048', TRUE),
('IN-400-03', 'WBS-400', 'Canalización conduit 3/4" y 1"', 'CON', 'm', 100, 'A-TK1048', TRUE),
('IN-400-04', 'WBS-400', 'Tendido conductores caudalímetro a IO', 'CBL', 'm', 80, 'A-TK1048', TRUE),
('IN-400-05', 'WBS-400', 'Tendido conductores caudalímetro a Tx', 'CBL', 'm', 30, 'A-TK1048', TRUE),
('IN-400-06', 'WBS-400', 'Megado, continuidad, tagueado y conexionado', 'TER', 'u', 3, 'A-TK1048', TRUE),
('IN-400-07', 'WBS-400', 'Aterrado con v/a 6mm (TK1048)', 'PAT', 'm', 110, 'A-TK1048', TRUE),
('IN-500-01', 'WBS-500', 'Soldadura y montaje soporte conduit 3/4"', 'SPT', 'u', 10, 'A-FILT', TRUE),
('IN-500-02', 'WBS-500', 'Canalización conduit 3/4"', 'CON', 'm', 40, 'A-FILT', TRUE),
('IN-500-03', 'WBS-500', 'Tendido conductor desde PCV a IO-1002', 'CBL', 'm', 100, 'A-FILT', TRUE),
('IN-500-04', 'WBS-500', 'Megado, continuidad, tagueado y conexionado', 'TER', 'u', 2, 'A-FILT', TRUE)
ON CONFLICT (control_item_id) DO UPDATE SET wbs_id=EXCLUDED.wbs_id, item_descripcion=EXCLUDED.item_descripcion, familia_id=EXCLUDED.familia_id, unidad_id=EXCLUDED.unidad_id, cantidad_base=EXCLUDED.cantidad_base, area_codigo=EXCLUDED.area_codigo, activo=EXCLUDED.activo;

COMMIT;
