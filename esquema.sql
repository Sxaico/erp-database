--
-- PostgreSQL database dump
--

\restrict cwN11V9mPpXuADfpPf3yBgfh9QwQrwUclgHxVuIy8cgOTn2uH39hc8XPSDQSzwa

-- Dumped from database version 17.7 (Debian 17.7-3.pgdg13+1)
-- Dumped by pg_dump version 17.7 (Debian 17.7-3.pgdg13+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: sigco; Type: SCHEMA; Schema: -; Owner: erp_user
--

CREATE SCHEMA sigco;


ALTER SCHEMA sigco OWNER TO erp_user;

--
-- Name: sigco_int; Type: SCHEMA; Schema: -; Owner: erp_user
--

CREATE SCHEMA sigco_int;


ALTER SCHEMA sigco_int OWNER TO erp_user;

--
-- Name: sigco_rpt; Type: SCHEMA; Schema: -; Owner: erp_user
--

CREATE SCHEMA sigco_rpt;


ALTER SCHEMA sigco_rpt OWNER TO erp_user;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: fn_pd_header_estado_audit(); Type: FUNCTION; Schema: sigco; Owner: erp_user
--

CREATE FUNCTION sigco.fn_pd_header_estado_audit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF NEW.estado IS DISTINCT FROM OLD.estado THEN
    IF NEW.estado = 'CERRADO' THEN
      NEW.cerrado_at := COALESCE(NEW.cerrado_at, now());
    ELSIF NEW.estado = 'BORRADOR' THEN
      NEW.reabierto_at := COALESCE(NEW.reabierto_at, now());
    END IF;
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION sigco.fn_pd_header_estado_audit() OWNER TO erp_user;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: departamentos; Type: TABLE; Schema: public; Owner: erp_user
--

CREATE TABLE public.departamentos (
    id integer NOT NULL,
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    nombre text NOT NULL,
    descripcion text,
    organizacion_id integer,
    departamento_padre_id integer,
    responsable_id integer,
    activo boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.departamentos OWNER TO erp_user;

--
-- Name: departamentos_id_seq; Type: SEQUENCE; Schema: public; Owner: erp_user
--

CREATE SEQUENCE public.departamentos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.departamentos_id_seq OWNER TO erp_user;

--
-- Name: departamentos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: erp_user
--

ALTER SEQUENCE public.departamentos_id_seq OWNED BY public.departamentos.id;


--
-- Name: directus_activity; Type: TABLE; Schema: public; Owner: erp_user
--

CREATE TABLE public.directus_activity (
    id integer NOT NULL,
    action character varying(45) NOT NULL,
    "user" uuid,
    "timestamp" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    ip character varying(50),
    user_agent text,
    collection character varying(64) NOT NULL,
    item character varying(255) NOT NULL,
    comment text,
    origin character varying(255)
);


ALTER TABLE public.directus_activity OWNER TO erp_user;

--
-- Name: directus_activity_id_seq; Type: SEQUENCE; Schema: public; Owner: erp_user
--

CREATE SEQUENCE public.directus_activity_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.directus_activity_id_seq OWNER TO erp_user;

--
-- Name: directus_activity_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: erp_user
--

ALTER SEQUENCE public.directus_activity_id_seq OWNED BY public.directus_activity.id;


--
-- Name: directus_collections; Type: TABLE; Schema: public; Owner: erp_user
--

CREATE TABLE public.directus_collections (
    collection character varying(64) NOT NULL,
    icon character varying(30),
    note text,
    display_template character varying(255),
    hidden boolean DEFAULT false NOT NULL,
    singleton boolean DEFAULT false NOT NULL,
    translations json,
    archive_field character varying(64),
    archive_app_filter boolean DEFAULT true NOT NULL,
    archive_value character varying(255),
    unarchive_value character varying(255),
    sort_field character varying(64),
    accountability character varying(255) DEFAULT 'all'::character varying,
    color character varying(255),
    item_duplication_fields json,
    sort integer,
    "group" character varying(64),
    collapse character varying(255) DEFAULT 'open'::character varying NOT NULL,
    preview_url character varying(255),
    versioning boolean DEFAULT false NOT NULL
);


ALTER TABLE public.directus_collections OWNER TO erp_user;

--
-- Name: directus_dashboards; Type: TABLE; Schema: public; Owner: erp_user
--

CREATE TABLE public.directus_dashboards (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    icon character varying(30) DEFAULT 'dashboard'::character varying NOT NULL,
    note text,
    date_created timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    user_created uuid,
    color character varying(255)
);


ALTER TABLE public.directus_dashboards OWNER TO erp_user;

--
-- Name: directus_extensions; Type: TABLE; Schema: public; Owner: erp_user
--

CREATE TABLE public.directus_extensions (
    enabled boolean DEFAULT true NOT NULL,
    id uuid NOT NULL,
    folder character varying(255) NOT NULL,
    source character varying(255) NOT NULL,
    bundle uuid
);


ALTER TABLE public.directus_extensions OWNER TO erp_user;

--
-- Name: directus_fields; Type: TABLE; Schema: public; Owner: erp_user
--

CREATE TABLE public.directus_fields (
    id integer NOT NULL,
    collection character varying(64) NOT NULL,
    field character varying(64) NOT NULL,
    special character varying(64),
    interface character varying(64),
    options json,
    display character varying(64),
    display_options json,
    readonly boolean DEFAULT false NOT NULL,
    hidden boolean DEFAULT false NOT NULL,
    sort integer,
    width character varying(30) DEFAULT 'full'::character varying,
    translations json,
    note text,
    conditions json,
    required boolean DEFAULT false,
    "group" character varying(64),
    validation json,
    validation_message text
);


ALTER TABLE public.directus_fields OWNER TO erp_user;

--
-- Name: directus_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: erp_user
--

CREATE SEQUENCE public.directus_fields_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.directus_fields_id_seq OWNER TO erp_user;

--
-- Name: directus_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: erp_user
--

ALTER SEQUENCE public.directus_fields_id_seq OWNED BY public.directus_fields.id;


--
-- Name: directus_files; Type: TABLE; Schema: public; Owner: erp_user
--

CREATE TABLE public.directus_files (
    id uuid NOT NULL,
    storage character varying(255) NOT NULL,
    filename_disk character varying(255),
    filename_download character varying(255) NOT NULL,
    title character varying(255),
    type character varying(255),
    folder uuid,
    uploaded_by uuid,
    uploaded_on timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    modified_by uuid,
    modified_on timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    charset character varying(50),
    filesize bigint,
    width integer,
    height integer,
    duration integer,
    embed character varying(200),
    description text,
    location text,
    tags text,
    metadata json,
    focal_point_x integer,
    focal_point_y integer
);


ALTER TABLE public.directus_files OWNER TO erp_user;

--
-- Name: directus_flows; Type: TABLE; Schema: public; Owner: erp_user
--

CREATE TABLE public.directus_flows (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    icon character varying(30),
    color character varying(255),
    description text,
    status character varying(255) DEFAULT 'active'::character varying NOT NULL,
    trigger character varying(255),
    accountability character varying(255) DEFAULT 'all'::character varying,
    options json,
    operation uuid,
    date_created timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    user_created uuid
);


ALTER TABLE public.directus_flows OWNER TO erp_user;

--
-- Name: directus_folders; Type: TABLE; Schema: public; Owner: erp_user
--

CREATE TABLE public.directus_folders (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    parent uuid
);


ALTER TABLE public.directus_folders OWNER TO erp_user;

--
-- Name: directus_migrations; Type: TABLE; Schema: public; Owner: erp_user
--

CREATE TABLE public.directus_migrations (
    version character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    "timestamp" timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.directus_migrations OWNER TO erp_user;

--
-- Name: directus_notifications; Type: TABLE; Schema: public; Owner: erp_user
--

CREATE TABLE public.directus_notifications (
    id integer NOT NULL,
    "timestamp" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    status character varying(255) DEFAULT 'inbox'::character varying,
    recipient uuid NOT NULL,
    sender uuid,
    subject character varying(255) NOT NULL,
    message text,
    collection character varying(64),
    item character varying(255)
);


ALTER TABLE public.directus_notifications OWNER TO erp_user;

--
-- Name: directus_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: erp_user
--

CREATE SEQUENCE public.directus_notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.directus_notifications_id_seq OWNER TO erp_user;

--
-- Name: directus_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: erp_user
--

ALTER SEQUENCE public.directus_notifications_id_seq OWNED BY public.directus_notifications.id;


--
-- Name: directus_operations; Type: TABLE; Schema: public; Owner: erp_user
--

CREATE TABLE public.directus_operations (
    id uuid NOT NULL,
    name character varying(255),
    key character varying(255) NOT NULL,
    type character varying(255) NOT NULL,
    position_x integer NOT NULL,
    position_y integer NOT NULL,
    options json,
    resolve uuid,
    reject uuid,
    flow uuid NOT NULL,
    date_created timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    user_created uuid
);


ALTER TABLE public.directus_operations OWNER TO erp_user;

--
-- Name: directus_panels; Type: TABLE; Schema: public; Owner: erp_user
--

CREATE TABLE public.directus_panels (
    id uuid NOT NULL,
    dashboard uuid NOT NULL,
    name character varying(255),
    icon character varying(30) DEFAULT NULL::character varying,
    color character varying(10),
    show_header boolean DEFAULT false NOT NULL,
    note text,
    type character varying(255) NOT NULL,
    position_x integer NOT NULL,
    position_y integer NOT NULL,
    width integer NOT NULL,
    height integer NOT NULL,
    options json,
    date_created timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    user_created uuid
);


ALTER TABLE public.directus_panels OWNER TO erp_user;

--
-- Name: directus_permissions; Type: TABLE; Schema: public; Owner: erp_user
--

CREATE TABLE public.directus_permissions (
    id integer NOT NULL,
    role uuid,
    collection character varying(64) NOT NULL,
    action character varying(10) NOT NULL,
    permissions json,
    validation json,
    presets json,
    fields text
);


ALTER TABLE public.directus_permissions OWNER TO erp_user;

--
-- Name: directus_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: erp_user
--

CREATE SEQUENCE public.directus_permissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.directus_permissions_id_seq OWNER TO erp_user;

--
-- Name: directus_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: erp_user
--

ALTER SEQUENCE public.directus_permissions_id_seq OWNED BY public.directus_permissions.id;


--
-- Name: directus_presets; Type: TABLE; Schema: public; Owner: erp_user
--

CREATE TABLE public.directus_presets (
    id integer NOT NULL,
    bookmark character varying(255),
    "user" uuid,
    role uuid,
    collection character varying(64),
    search character varying(100),
    layout character varying(100) DEFAULT 'tabular'::character varying,
    layout_query json,
    layout_options json,
    refresh_interval integer,
    filter json,
    icon character varying(30) DEFAULT 'bookmark'::character varying,
    color character varying(255)
);


ALTER TABLE public.directus_presets OWNER TO erp_user;

--
-- Name: directus_presets_id_seq; Type: SEQUENCE; Schema: public; Owner: erp_user
--

CREATE SEQUENCE public.directus_presets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.directus_presets_id_seq OWNER TO erp_user;

--
-- Name: directus_presets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: erp_user
--

ALTER SEQUENCE public.directus_presets_id_seq OWNED BY public.directus_presets.id;


--
-- Name: directus_relations; Type: TABLE; Schema: public; Owner: erp_user
--

CREATE TABLE public.directus_relations (
    id integer NOT NULL,
    many_collection character varying(64) NOT NULL,
    many_field character varying(64) NOT NULL,
    one_collection character varying(64),
    one_field character varying(64),
    one_collection_field character varying(64),
    one_allowed_collections text,
    junction_field character varying(64),
    sort_field character varying(64),
    one_deselect_action character varying(255) DEFAULT 'nullify'::character varying NOT NULL
);


ALTER TABLE public.directus_relations OWNER TO erp_user;

--
-- Name: directus_relations_id_seq; Type: SEQUENCE; Schema: public; Owner: erp_user
--

CREATE SEQUENCE public.directus_relations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.directus_relations_id_seq OWNER TO erp_user;

--
-- Name: directus_relations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: erp_user
--

ALTER SEQUENCE public.directus_relations_id_seq OWNED BY public.directus_relations.id;


--
-- Name: directus_revisions; Type: TABLE; Schema: public; Owner: erp_user
--

CREATE TABLE public.directus_revisions (
    id integer NOT NULL,
    activity integer NOT NULL,
    collection character varying(64) NOT NULL,
    item character varying(255) NOT NULL,
    data json,
    delta json,
    parent integer,
    version uuid
);


ALTER TABLE public.directus_revisions OWNER TO erp_user;

--
-- Name: directus_revisions_id_seq; Type: SEQUENCE; Schema: public; Owner: erp_user
--

CREATE SEQUENCE public.directus_revisions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.directus_revisions_id_seq OWNER TO erp_user;

--
-- Name: directus_revisions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: erp_user
--

ALTER SEQUENCE public.directus_revisions_id_seq OWNED BY public.directus_revisions.id;


--
-- Name: directus_roles; Type: TABLE; Schema: public; Owner: erp_user
--

CREATE TABLE public.directus_roles (
    id uuid NOT NULL,
    name character varying(100) NOT NULL,
    icon character varying(30) DEFAULT 'supervised_user_circle'::character varying NOT NULL,
    description text,
    ip_access text,
    enforce_tfa boolean DEFAULT false NOT NULL,
    admin_access boolean DEFAULT false NOT NULL,
    app_access boolean DEFAULT true NOT NULL
);


ALTER TABLE public.directus_roles OWNER TO erp_user;

--
-- Name: directus_sessions; Type: TABLE; Schema: public; Owner: erp_user
--

CREATE TABLE public.directus_sessions (
    token character varying(64) NOT NULL,
    "user" uuid,
    expires timestamp with time zone NOT NULL,
    ip character varying(255),
    user_agent text,
    share uuid,
    origin character varying(255)
);


ALTER TABLE public.directus_sessions OWNER TO erp_user;

--
-- Name: directus_settings; Type: TABLE; Schema: public; Owner: erp_user
--

CREATE TABLE public.directus_settings (
    id integer NOT NULL,
    project_name character varying(100) DEFAULT 'Directus'::character varying NOT NULL,
    project_url character varying(255),
    project_color character varying(255) DEFAULT '#6644FF'::character varying NOT NULL,
    project_logo uuid,
    public_foreground uuid,
    public_background uuid,
    public_note text,
    auth_login_attempts integer DEFAULT 25,
    auth_password_policy character varying(100),
    storage_asset_transform character varying(7) DEFAULT 'all'::character varying,
    storage_asset_presets json,
    custom_css text,
    storage_default_folder uuid,
    basemaps json,
    mapbox_key character varying(255),
    module_bar json,
    project_descriptor character varying(100),
    default_language character varying(255) DEFAULT 'en-US'::character varying NOT NULL,
    custom_aspect_ratios json,
    public_favicon uuid,
    default_appearance character varying(255) DEFAULT 'auto'::character varying NOT NULL,
    default_theme_light character varying(255),
    theme_light_overrides json,
    default_theme_dark character varying(255),
    theme_dark_overrides json,
    report_error_url character varying(255),
    report_bug_url character varying(255),
    report_feature_url character varying(255),
    public_registration boolean DEFAULT false NOT NULL,
    public_registration_verify_email boolean DEFAULT true NOT NULL,
    public_registration_role uuid,
    public_registration_email_filter json
);


ALTER TABLE public.directus_settings OWNER TO erp_user;

--
-- Name: directus_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: erp_user
--

CREATE SEQUENCE public.directus_settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.directus_settings_id_seq OWNER TO erp_user;

--
-- Name: directus_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: erp_user
--

ALTER SEQUENCE public.directus_settings_id_seq OWNED BY public.directus_settings.id;


--
-- Name: directus_shares; Type: TABLE; Schema: public; Owner: erp_user
--

CREATE TABLE public.directus_shares (
    id uuid NOT NULL,
    name character varying(255),
    collection character varying(64) NOT NULL,
    item character varying(255) NOT NULL,
    role uuid,
    password character varying(255),
    user_created uuid,
    date_created timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    date_start timestamp with time zone,
    date_end timestamp with time zone,
    times_used integer DEFAULT 0,
    max_uses integer
);


ALTER TABLE public.directus_shares OWNER TO erp_user;

--
-- Name: directus_translations; Type: TABLE; Schema: public; Owner: erp_user
--

CREATE TABLE public.directus_translations (
    id uuid NOT NULL,
    language character varying(255) NOT NULL,
    key character varying(255) NOT NULL,
    value text NOT NULL
);


ALTER TABLE public.directus_translations OWNER TO erp_user;

--
-- Name: directus_users; Type: TABLE; Schema: public; Owner: erp_user
--

CREATE TABLE public.directus_users (
    id uuid NOT NULL,
    first_name character varying(50),
    last_name character varying(50),
    email character varying(128),
    password character varying(255),
    location character varying(255),
    title character varying(50),
    description text,
    tags json,
    avatar uuid,
    language character varying(255) DEFAULT NULL::character varying,
    tfa_secret character varying(255),
    status character varying(16) DEFAULT 'active'::character varying NOT NULL,
    role uuid,
    token character varying(255),
    last_access timestamp with time zone,
    last_page character varying(255),
    provider character varying(128) DEFAULT 'default'::character varying NOT NULL,
    external_identifier character varying(255),
    auth_data json,
    email_notifications boolean DEFAULT true,
    appearance character varying(255),
    theme_dark character varying(255),
    theme_light character varying(255),
    theme_light_overrides json,
    theme_dark_overrides json
);


ALTER TABLE public.directus_users OWNER TO erp_user;

--
-- Name: directus_versions; Type: TABLE; Schema: public; Owner: erp_user
--

CREATE TABLE public.directus_versions (
    id uuid NOT NULL,
    key character varying(64) NOT NULL,
    name character varying(255),
    collection character varying(64) NOT NULL,
    item character varying(255) NOT NULL,
    hash character varying(255),
    date_created timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    date_updated timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    user_created uuid,
    user_updated uuid
);


ALTER TABLE public.directus_versions OWNER TO erp_user;

--
-- Name: directus_webhooks; Type: TABLE; Schema: public; Owner: erp_user
--

CREATE TABLE public.directus_webhooks (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    method character varying(10) DEFAULT 'POST'::character varying NOT NULL,
    url character varying(255) NOT NULL,
    status character varying(10) DEFAULT 'active'::character varying NOT NULL,
    data boolean DEFAULT true NOT NULL,
    actions character varying(100) NOT NULL,
    collections character varying(255) NOT NULL,
    headers json,
    was_active_before_deprecation boolean DEFAULT false NOT NULL,
    migrated_flow uuid
);


ALTER TABLE public.directus_webhooks OWNER TO erp_user;

--
-- Name: directus_webhooks_id_seq; Type: SEQUENCE; Schema: public; Owner: erp_user
--

CREATE SEQUENCE public.directus_webhooks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.directus_webhooks_id_seq OWNER TO erp_user;

--
-- Name: directus_webhooks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: erp_user
--

ALTER SEQUENCE public.directus_webhooks_id_seq OWNED BY public.directus_webhooks.id;


--
-- Name: organizaciones; Type: TABLE; Schema: public; Owner: erp_user
--

CREATE TABLE public.organizaciones (
    id integer NOT NULL,
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    nombre text NOT NULL,
    razon_social text,
    rfc text,
    telefono text,
    email text,
    direccion text,
    ciudad text,
    estado text,
    codigo_postal text,
    pais text DEFAULT 'Argentina'::text NOT NULL,
    activa boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.organizaciones OWNER TO erp_user;

--
-- Name: organizaciones_id_seq; Type: SEQUENCE; Schema: public; Owner: erp_user
--

CREATE SEQUENCE public.organizaciones_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.organizaciones_id_seq OWNER TO erp_user;

--
-- Name: organizaciones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: erp_user
--

ALTER SEQUENCE public.organizaciones_id_seq OWNED BY public.organizaciones.id;


--
-- Name: proyecto_miembros; Type: TABLE; Schema: public; Owner: erp_user
--

CREATE TABLE public.proyecto_miembros (
    id integer NOT NULL,
    proyecto_id integer NOT NULL,
    usuario_id integer NOT NULL,
    rol_en_proyecto character varying(30) DEFAULT 'MIEMBRO'::character varying,
    creado_en timestamp with time zone DEFAULT now()
);


ALTER TABLE public.proyecto_miembros OWNER TO erp_user;

--
-- Name: proyecto_miembros_id_seq; Type: SEQUENCE; Schema: public; Owner: erp_user
--

CREATE SEQUENCE public.proyecto_miembros_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.proyecto_miembros_id_seq OWNER TO erp_user;

--
-- Name: proyecto_miembros_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: erp_user
--

ALTER SEQUENCE public.proyecto_miembros_id_seq OWNED BY public.proyecto_miembros.id;


--
-- Name: proyectos; Type: TABLE; Schema: public; Owner: erp_user
--

CREATE TABLE public.proyectos (
    id integer NOT NULL,
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    codigo text,
    nombre text NOT NULL,
    descripcion text,
    organizacion_id integer,
    gerente_proyecto_id integer,
    sponsor_id integer,
    prioridad smallint DEFAULT 3 NOT NULL,
    estado text DEFAULT 'EN_PROGRESO'::text NOT NULL,
    presupuesto_monto numeric(14,2) DEFAULT 0,
    avance_pct numeric(5,2) DEFAULT 0,
    fecha_inicio date,
    fecha_fin_plan date,
    fecha_fin_real date,
    activo boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.proyectos OWNER TO erp_user;

--
-- Name: proyectos_id_seq; Type: SEQUENCE; Schema: public; Owner: erp_user
--

CREATE SEQUENCE public.proyectos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.proyectos_id_seq OWNER TO erp_user;

--
-- Name: proyectos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: erp_user
--

ALTER SEQUENCE public.proyectos_id_seq OWNED BY public.proyectos.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: erp_user
--

CREATE TABLE public.roles (
    id integer NOT NULL,
    nombre text NOT NULL,
    descripcion text,
    activo boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.roles OWNER TO erp_user;

--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: erp_user
--

CREATE SEQUENCE public.roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.roles_id_seq OWNER TO erp_user;

--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: erp_user
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: tareas; Type: TABLE; Schema: public; Owner: erp_user
--

CREATE TABLE public.tareas (
    id integer NOT NULL,
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    proyecto_id integer NOT NULL,
    titulo text NOT NULL,
    descripcion text,
    estado text DEFAULT 'PENDIENTE'::text NOT NULL,
    prioridad smallint DEFAULT 3 NOT NULL,
    asignado_a integer,
    estimado_horas numeric(10,2) DEFAULT 0,
    real_horas numeric(10,2) DEFAULT 0,
    fecha_inicio date,
    fecha_fin_plan date,
    fecha_fin_real date,
    activo boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.tareas OWNER TO erp_user;

--
-- Name: tareas_id_seq; Type: SEQUENCE; Schema: public; Owner: erp_user
--

CREATE SEQUENCE public.tareas_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tareas_id_seq OWNER TO erp_user;

--
-- Name: tareas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: erp_user
--

ALTER SEQUENCE public.tareas_id_seq OWNED BY public.tareas.id;


--
-- Name: usuario_departamentos; Type: TABLE; Schema: public; Owner: erp_user
--

CREATE TABLE public.usuario_departamentos (
    id integer NOT NULL,
    usuario_id integer,
    departamento_id integer,
    es_responsable boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.usuario_departamentos OWNER TO erp_user;

--
-- Name: usuario_departamentos_id_seq; Type: SEQUENCE; Schema: public; Owner: erp_user
--

CREATE SEQUENCE public.usuario_departamentos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usuario_departamentos_id_seq OWNER TO erp_user;

--
-- Name: usuario_departamentos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: erp_user
--

ALTER SEQUENCE public.usuario_departamentos_id_seq OWNED BY public.usuario_departamentos.id;


--
-- Name: usuario_roles; Type: TABLE; Schema: public; Owner: erp_user
--

CREATE TABLE public.usuario_roles (
    id integer NOT NULL,
    usuario_id integer NOT NULL,
    rol_id integer NOT NULL,
    asignado_por integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.usuario_roles OWNER TO erp_user;

--
-- Name: usuario_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: erp_user
--

CREATE SEQUENCE public.usuario_roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usuario_roles_id_seq OWNER TO erp_user;

--
-- Name: usuario_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: erp_user
--

ALTER SEQUENCE public.usuario_roles_id_seq OWNED BY public.usuario_roles.id;


--
-- Name: usuarios; Type: TABLE; Schema: public; Owner: erp_user
--

CREATE TABLE public.usuarios (
    id integer NOT NULL,
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    email text NOT NULL,
    password_hash text NOT NULL,
    nombre text NOT NULL,
    apellido text NOT NULL,
    telefono text,
    activo boolean DEFAULT true NOT NULL,
    ultimo_login timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.usuarios OWNER TO erp_user;

--
-- Name: usuarios_id_seq; Type: SEQUENCE; Schema: public; Owner: erp_user
--

CREATE SEQUENCE public.usuarios_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usuarios_id_seq OWNER TO erp_user;

--
-- Name: usuarios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: erp_user
--

ALTER SEQUENCE public.usuarios_id_seq OWNED BY public.usuarios.id;


--
-- Name: vw_resumen_tareas_por_estado; Type: VIEW; Schema: public; Owner: erp_user
--

CREATE VIEW public.vw_resumen_tareas_por_estado AS
 SELECT p.id AS proyecto_id,
    p.nombre AS proyecto,
    t.estado,
    (count(*))::integer AS cantidad
   FROM (public.proyectos p
     JOIN public.tareas t ON (((t.proyecto_id = p.id) AND (t.deleted_at IS NULL))))
  WHERE (p.deleted_at IS NULL)
  GROUP BY p.id, p.nombre, t.estado
  ORDER BY p.id, t.estado;


ALTER VIEW public.vw_resumen_tareas_por_estado OWNER TO erp_user;

--
-- Name: boq_control; Type: TABLE; Schema: sigco; Owner: erp_user
--

CREATE TABLE sigco.boq_control (
    control_item_id character varying NOT NULL,
    wbs_id character varying NOT NULL,
    item_descripcion text NOT NULL,
    familia_id character varying,
    unidad_id character varying,
    cantidad_base numeric(14,3),
    area_codigo character varying,
    activo boolean DEFAULT true NOT NULL,
    project_id character varying DEFAULT 'P0001'::character varying
);


ALTER TABLE sigco.boq_control OWNER TO erp_user;

--
-- Name: cat_areas_frentes; Type: TABLE; Schema: sigco; Owner: erp_user
--

CREATE TABLE sigco.cat_areas_frentes (
    area_codigo character varying NOT NULL,
    area_nombre character varying NOT NULL,
    descripcion text,
    activo boolean DEFAULT true NOT NULL
);


ALTER TABLE sigco.cat_areas_frentes OWNER TO erp_user;

--
-- Name: cat_categorias_personal; Type: TABLE; Schema: sigco; Owner: erp_user
--

CREATE TABLE sigco.cat_categorias_personal (
    categoria_id character varying NOT NULL,
    categoria_nombre character varying NOT NULL,
    tipo character varying NOT NULL,
    descripcion text,
    activo boolean DEFAULT true NOT NULL,
    CONSTRAINT ck_cat_personal_tipo CHECK (((tipo)::text = ANY (ARRAY[('Directo'::character varying)::text, ('Indirecto'::character varying)::text])))
);


ALTER TABLE sigco.cat_categorias_personal OWNER TO erp_user;

--
-- Name: cat_equipos; Type: TABLE; Schema: sigco; Owner: erp_user
--

CREATE TABLE sigco.cat_equipos (
    equipo_id character varying NOT NULL,
    equipo_nombre character varying NOT NULL,
    equipo_tipo character varying,
    activo boolean DEFAULT true NOT NULL
);


ALTER TABLE sigco.cat_equipos OWNER TO erp_user;

--
-- Name: cat_etapas; Type: TABLE; Schema: sigco; Owner: erp_user
--

CREATE TABLE sigco.cat_etapas (
    etapa_id character varying NOT NULL,
    etapa_nombre character varying NOT NULL,
    etapa_definicion text,
    orden integer,
    activo boolean DEFAULT true NOT NULL
);


ALTER TABLE sigco.cat_etapas OWNER TO erp_user;

--
-- Name: cat_familias; Type: TABLE; Schema: sigco; Owner: erp_user
--

CREATE TABLE sigco.cat_familias (
    familia_id character varying NOT NULL,
    familia_nombre character varying NOT NULL,
    alcance_tecnico text
);


ALTER TABLE sigco.cat_familias OWNER TO erp_user;

--
-- Name: cat_restricciones; Type: TABLE; Schema: sigco; Owner: erp_user
--

CREATE TABLE sigco.cat_restricciones (
    restriccion_id character varying NOT NULL,
    categoria character varying,
    restriccion_nombre character varying NOT NULL,
    restriccion_definicion text,
    activo boolean DEFAULT true NOT NULL
);


ALTER TABLE sigco.cat_restricciones OWNER TO erp_user;

--
-- Name: cat_unidades; Type: TABLE; Schema: sigco; Owner: erp_user
--

CREATE TABLE sigco.cat_unidades (
    unidad_id character varying NOT NULL,
    unidad_tipo character varying,
    uso_tipico text,
    activo boolean DEFAULT true NOT NULL
);


ALTER TABLE sigco.cat_unidades OWNER TO erp_user;

--
-- Name: pd_equipos_hm; Type: TABLE; Schema: sigco; Owner: erp_user
--

CREATE TABLE sigco.pd_equipos_hm (
    id_registro bigint NOT NULL,
    pd_id character varying NOT NULL,
    equipo_id character varying NOT NULL,
    horas_maquina numeric(12,2) NOT NULL,
    area_codigo character varying,
    observacion text
);


ALTER TABLE sigco.pd_equipos_hm OWNER TO erp_user;

--
-- Name: pd_equipos_hm_id_registro_seq; Type: SEQUENCE; Schema: sigco; Owner: erp_user
--

CREATE SEQUENCE sigco.pd_equipos_hm_id_registro_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE sigco.pd_equipos_hm_id_registro_seq OWNER TO erp_user;

--
-- Name: pd_equipos_hm_id_registro_seq; Type: SEQUENCE OWNED BY; Schema: sigco; Owner: erp_user
--

ALTER SEQUENCE sigco.pd_equipos_hm_id_registro_seq OWNED BY sigco.pd_equipos_hm.id_registro;


--
-- Name: pd_header; Type: TABLE; Schema: sigco; Owner: erp_user
--

CREATE TABLE sigco.pd_header (
    pd_id character varying DEFAULT (gen_random_uuid())::text NOT NULL,
    fecha_pd date NOT NULL,
    responsable character varying,
    hora_entrada time without time zone,
    hora_salida time without time zone,
    clima character varying,
    plan_manana text,
    observaciones_generales text,
    fecha_carga timestamp with time zone DEFAULT now() NOT NULL,
    project_id character varying DEFAULT 'P0001'::character varying,
    estado text DEFAULT 'BORRADOR'::text NOT NULL,
    cerrado_at timestamp with time zone,
    cerrado_por text,
    reabierto_at timestamp with time zone,
    reabierto_por text,
    CONSTRAINT pd_header_estado_chk CHECK ((estado = ANY (ARRAY['BORRADOR'::text, 'CERRADO'::text])))
);


ALTER TABLE sigco.pd_header OWNER TO erp_user;

--
-- Name: pd_personal_hh; Type: TABLE; Schema: sigco; Owner: erp_user
--

CREATE TABLE sigco.pd_personal_hh (
    id_registro bigint NOT NULL,
    pd_id character varying NOT NULL,
    persona_nombre character varying NOT NULL,
    categoria_id character varying NOT NULL,
    horas numeric(12,2) NOT NULL,
    area_codigo character varying,
    observacion text
);


ALTER TABLE sigco.pd_personal_hh OWNER TO erp_user;

--
-- Name: pd_personal_hh_id_registro_seq; Type: SEQUENCE; Schema: sigco; Owner: erp_user
--

CREATE SEQUENCE sigco.pd_personal_hh_id_registro_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE sigco.pd_personal_hh_id_registro_seq OWNER TO erp_user;

--
-- Name: pd_personal_hh_id_registro_seq; Type: SEQUENCE OWNED BY; Schema: sigco; Owner: erp_user
--

ALTER SEQUENCE sigco.pd_personal_hh_id_registro_seq OWNED BY sigco.pd_personal_hh.id_registro;


--
-- Name: pd_produccion; Type: TABLE; Schema: sigco; Owner: erp_user
--

CREATE TABLE sigco.pd_produccion (
    id_registro bigint NOT NULL,
    pd_id character varying NOT NULL,
    control_item_id character varying NOT NULL,
    etapa_id character varying NOT NULL,
    cantidad_dia numeric(14,3),
    hh_tarea numeric(12,2),
    personas_tarea integer,
    ubicacion_referencia text,
    observacion_linea text
);


ALTER TABLE sigco.pd_produccion OWNER TO erp_user;

--
-- Name: pd_produccion_fotos; Type: TABLE; Schema: sigco; Owner: erp_user
--

CREATE TABLE sigco.pd_produccion_fotos (
    id_registro bigint NOT NULL,
    produccion_id bigint NOT NULL,
    file_id uuid NOT NULL,
    descripcion text,
    orden integer DEFAULT 1,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE sigco.pd_produccion_fotos OWNER TO erp_user;

--
-- Name: pd_produccion_fotos_id_registro_seq; Type: SEQUENCE; Schema: sigco; Owner: erp_user
--

CREATE SEQUENCE sigco.pd_produccion_fotos_id_registro_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE sigco.pd_produccion_fotos_id_registro_seq OWNER TO erp_user;

--
-- Name: pd_produccion_fotos_id_registro_seq; Type: SEQUENCE OWNED BY; Schema: sigco; Owner: erp_user
--

ALTER SEQUENCE sigco.pd_produccion_fotos_id_registro_seq OWNED BY sigco.pd_produccion_fotos.id_registro;


--
-- Name: pd_produccion_id_registro_seq; Type: SEQUENCE; Schema: sigco; Owner: erp_user
--

CREATE SEQUENCE sigco.pd_produccion_id_registro_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE sigco.pd_produccion_id_registro_seq OWNER TO erp_user;

--
-- Name: pd_produccion_id_registro_seq; Type: SEQUENCE OWNED BY; Schema: sigco; Owner: erp_user
--

ALTER SEQUENCE sigco.pd_produccion_id_registro_seq OWNED BY sigco.pd_produccion.id_registro;


--
-- Name: pd_restricciones; Type: TABLE; Schema: sigco; Owner: erp_user
--

CREATE TABLE sigco.pd_restricciones (
    id_registro bigint NOT NULL,
    pd_id character varying NOT NULL,
    restriccion_id character varying NOT NULL,
    horas_impacto numeric(12,2),
    area_codigo character varying,
    descripcion_evento text,
    accion_tomada text,
    CONSTRAINT ck_pd_restricciones_horas_nonneg CHECK (((horas_impacto IS NULL) OR (horas_impacto >= (0)::numeric)))
);


ALTER TABLE sigco.pd_restricciones OWNER TO erp_user;

--
-- Name: pd_restricciones_id_registro_seq; Type: SEQUENCE; Schema: sigco; Owner: erp_user
--

CREATE SEQUENCE sigco.pd_restricciones_id_registro_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE sigco.pd_restricciones_id_registro_seq OWNER TO erp_user;

--
-- Name: pd_restricciones_id_registro_seq; Type: SEQUENCE OWNED BY; Schema: sigco; Owner: erp_user
--

ALTER SEQUENCE sigco.pd_restricciones_id_registro_seq OWNED BY sigco.pd_restricciones.id_registro;


--
-- Name: projects; Type: TABLE; Schema: sigco; Owner: erp_user
--

CREATE TABLE sigco.projects (
    project_id character varying NOT NULL,
    project_nombre text NOT NULL,
    activo boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE sigco.projects OWNER TO erp_user;

--
-- Name: v_pd_files; Type: VIEW; Schema: sigco; Owner: erp_user
--

CREATE VIEW sigco.v_pd_files AS
 SELECT p.pd_id,
    pf.file_id
   FROM (sigco.pd_produccion p
     JOIN sigco.pd_produccion_fotos pf ON ((pf.produccion_id = p.id_registro)));


ALTER VIEW sigco.v_pd_files OWNER TO erp_user;

--
-- Name: wbs; Type: TABLE; Schema: sigco; Owner: erp_user
--

CREATE TABLE sigco.wbs (
    wbs_id character varying NOT NULL,
    wbs_nombre character varying NOT NULL,
    wbs_descripcion text,
    wbs_padre_id character varying,
    nivel integer,
    activo boolean DEFAULT true NOT NULL,
    project_id character varying DEFAULT 'P0001'::character varying
);


ALTER TABLE sigco.wbs OWNER TO erp_user;

--
-- Name: op_project_map; Type: TABLE; Schema: sigco_int; Owner: erp_user
--

CREATE TABLE sigco_int.op_project_map (
    sigco_project_id character varying NOT NULL,
    op_project_id integer NOT NULL,
    op_base_url text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE sigco_int.op_project_map OWNER TO erp_user;

--
-- Name: op_time_entry_dedupe; Type: TABLE; Schema: sigco_int; Owner: erp_user
--

CREATE TABLE sigco_int.op_time_entry_dedupe (
    dedupe_key text NOT NULL,
    op_time_entry_id integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE sigco_int.op_time_entry_dedupe OWNER TO erp_user;

--
-- Name: op_wp_map; Type: TABLE; Schema: sigco_int; Owner: erp_user
--

CREATE TABLE sigco_int.op_wp_map (
    sigco_project_id character varying NOT NULL,
    wbs_id character varying NOT NULL,
    op_work_package_id integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE sigco_int.op_wp_map OWNER TO erp_user;

--
-- Name: v_avance_wbs; Type: VIEW; Schema: sigco_int; Owner: erp_user
--

CREATE VIEW sigco_int.v_avance_wbs AS
 WITH etapa_final AS (
         SELECT e.etapa_id
           FROM sigco.cat_etapas e
          ORDER BY e.orden DESC
         LIMIT 1
        ), item_final AS (
         SELECT b.project_id AS sigco_project_id,
            b.wbs_id,
            b.control_item_id,
            (COALESCE(b.cantidad_base, (0)::numeric))::numeric(14,4) AS cantidad_base,
            (COALESCE(sum(
                CASE
                    WHEN ((p.etapa_id)::text = (( SELECT etapa_final.etapa_id
                       FROM etapa_final))::text) THEN COALESCE(p.cantidad_dia, (0)::numeric)
                    ELSE (0)::numeric
                END), (0)::numeric))::numeric(14,4) AS cantidad_final_acum
           FROM (sigco.boq_control b
             LEFT JOIN sigco.pd_produccion p ON (((p.control_item_id)::text = (b.control_item_id)::text)))
          GROUP BY b.project_id, b.wbs_id, b.control_item_id, b.cantidad_base
        ), wbs_tot AS (
         SELECT item_final.sigco_project_id,
            item_final.wbs_id,
            (sum(item_final.cantidad_base))::numeric(14,4) AS base_total,
            (sum(LEAST(item_final.cantidad_final_acum, item_final.cantidad_base)))::numeric(14,4) AS final_total
           FROM item_final
          GROUP BY item_final.sigco_project_id, item_final.wbs_id
        )
 SELECT sigco_project_id,
    wbs_id,
    base_total,
    final_total,
        CASE
            WHEN (base_total > (0)::numeric) THEN round(((final_total / base_total) * 100.0), 2)
            ELSE NULL::numeric
        END AS avance_pct
   FROM wbs_tot;


ALTER VIEW sigco_int.v_avance_wbs OWNER TO erp_user;

--
-- Name: v_hh_directas_wbs_dia; Type: VIEW; Schema: sigco_int; Owner: erp_user
--

CREATE VIEW sigco_int.v_hh_directas_wbs_dia AS
 SELECT h.project_id AS sigco_project_id,
    h.fecha_pd AS spent_on,
    b.wbs_id,
    (sum(COALESCE(p.hh_tarea, (0)::numeric)))::numeric(12,2) AS hh_directas
   FROM ((sigco.pd_produccion p
     JOIN sigco.pd_header h ON (((h.pd_id)::text = (p.pd_id)::text)))
     JOIN sigco.boq_control b ON (((b.control_item_id)::text = (p.control_item_id)::text)))
  GROUP BY h.project_id, h.fecha_pd, b.wbs_id;


ALTER VIEW sigco_int.v_hh_directas_wbs_dia OWNER TO erp_user;

--
-- Name: v_wbs_sin_wp; Type: VIEW; Schema: sigco_int; Owner: erp_user
--

CREATE VIEW sigco_int.v_wbs_sin_wp AS
 SELECT w.project_id AS sigco_project_id,
    w.wbs_id,
    w.wbs_nombre,
    w.nivel,
    w.wbs_padre_id
   FROM (sigco.wbs w
     LEFT JOIN sigco_int.op_wp_map m ON ((((m.sigco_project_id)::text = (w.project_id)::text) AND ((m.wbs_id)::text = (w.wbs_id)::text))))
  WHERE (m.wbs_id IS NULL);


ALTER VIEW sigco_int.v_wbs_sin_wp OWNER TO erp_user;

--
-- Name: v_kpi_boq_avance; Type: VIEW; Schema: sigco_rpt; Owner: erp_user
--

CREATE VIEW sigco_rpt.v_kpi_boq_avance AS
 WITH etapa_final AS (
         SELECT cat_etapas.etapa_id,
            cat_etapas.etapa_nombre,
            cat_etapas.orden
           FROM sigco.cat_etapas
          WHERE (COALESCE(cat_etapas.activo, true) = true)
          ORDER BY cat_etapas.orden DESC NULLS LAST
         LIMIT 1
        ), avance_final AS (
         SELECT p.control_item_id,
            sum(p.cantidad_dia) AS avance_final_acum
           FROM (sigco.pd_produccion p
             JOIN etapa_final ef_1 ON (((ef_1.etapa_id)::text = (p.etapa_id)::text)))
          GROUP BY p.control_item_id
        )
 SELECT b.control_item_id,
    b.item_descripcion,
    b.cantidad_base,
    COALESCE(af.avance_final_acum, (0)::numeric) AS avance_final_acum,
        CASE
            WHEN ((b.cantidad_base IS NULL) OR (b.cantidad_base = (0)::numeric)) THEN NULL::numeric
            ELSE round(((COALESCE(af.avance_final_acum, (0)::numeric) / b.cantidad_base) * (100)::numeric), 2)
        END AS pct_avance,
        CASE
            WHEN (b.cantidad_base IS NULL) THEN NULL::numeric
            ELSE (b.cantidad_base - COALESCE(af.avance_final_acum, (0)::numeric))
        END AS saldo,
    b.unidad_id,
    u.unidad_tipo,
    b.familia_id,
    f.familia_nombre,
    b.area_codigo,
    ar.area_nombre,
    b.wbs_id,
    w.wbs_nombre,
    ef.etapa_id AS etapa_final_id,
    ef.etapa_nombre AS etapa_final_nombre,
    ef.orden AS etapa_final_orden
   FROM ((((((sigco.boq_control b
     CROSS JOIN etapa_final ef)
     LEFT JOIN avance_final af ON (((af.control_item_id)::text = (b.control_item_id)::text)))
     LEFT JOIN sigco.cat_unidades u ON (((u.unidad_id)::text = (b.unidad_id)::text)))
     LEFT JOIN sigco.cat_familias f ON (((f.familia_id)::text = (b.familia_id)::text)))
     LEFT JOIN sigco.cat_areas_frentes ar ON (((ar.area_codigo)::text = (b.area_codigo)::text)))
     LEFT JOIN sigco.wbs w ON (((w.wbs_id)::text = (b.wbs_id)::text)))
  WHERE (COALESCE(b.activo, true) = true);


ALTER VIEW sigco_rpt.v_kpi_boq_avance OWNER TO erp_user;

--
-- Name: v_pd_header; Type: VIEW; Schema: sigco_rpt; Owner: erp_user
--

CREATE VIEW sigco_rpt.v_pd_header AS
 SELECT h.pd_id,
    h.fecha_pd,
    h.responsable,
    h.hora_entrada,
    h.hora_salida,
    h.clima,
    h.plan_manana,
    h.observaciones_generales,
    h.fecha_carga,
    COALESCE(hh.hh_total, (0)::numeric) AS hh_total,
    COALESCE(hm.hm_total, (0)::numeric) AS hm_total,
    COALESCE(pr.prod_lineas, (0)::bigint) AS prod_lineas,
    COALESCE(ft.fotos_total, (0)::bigint) AS fotos_total
   FROM ((((sigco.pd_header h
     LEFT JOIN ( SELECT pd_personal_hh.pd_id,
            sum(pd_personal_hh.horas) AS hh_total
           FROM sigco.pd_personal_hh
          GROUP BY pd_personal_hh.pd_id) hh ON (((hh.pd_id)::text = (h.pd_id)::text)))
     LEFT JOIN ( SELECT pd_equipos_hm.pd_id,
            sum(pd_equipos_hm.horas_maquina) AS hm_total
           FROM sigco.pd_equipos_hm
          GROUP BY pd_equipos_hm.pd_id) hm ON (((hm.pd_id)::text = (h.pd_id)::text)))
     LEFT JOIN ( SELECT pd_produccion.pd_id,
            count(*) AS prod_lineas
           FROM sigco.pd_produccion
          GROUP BY pd_produccion.pd_id) pr ON (((pr.pd_id)::text = (h.pd_id)::text)))
     LEFT JOIN ( SELECT p.pd_id,
            count(*) AS fotos_total
           FROM (sigco.pd_produccion_fotos pf
             JOIN sigco.pd_produccion p ON ((p.id_registro = pf.produccion_id)))
          GROUP BY p.pd_id) ft ON (((ft.pd_id)::text = (h.pd_id)::text)));


ALTER VIEW sigco_rpt.v_pd_header OWNER TO erp_user;

--
-- Name: v_kpi_diario; Type: VIEW; Schema: sigco_rpt; Owner: erp_user
--

CREATE VIEW sigco_rpt.v_kpi_diario AS
 SELECT fecha_pd,
    count(*) AS partes,
    sum(hh_total) AS hh_total,
    sum(hm_total) AS hm_total,
    sum(prod_lineas) AS prod_lineas,
    sum(fotos_total) AS fotos_total
   FROM sigco_rpt.v_pd_header
  GROUP BY fecha_pd
  ORDER BY fecha_pd DESC;


ALTER VIEW sigco_rpt.v_kpi_diario OWNER TO erp_user;

--
-- Name: v_kpi_pd_resumen; Type: VIEW; Schema: sigco_rpt; Owner: erp_user
--

CREATE VIEW sigco_rpt.v_kpi_pd_resumen AS
 SELECT pd_id,
    fecha_pd,
    responsable,
    hora_entrada,
    hora_salida,
    hh_total,
    hm_total,
    prod_lineas,
    fotos_total
   FROM sigco_rpt.v_pd_header vh;


ALTER VIEW sigco_rpt.v_kpi_pd_resumen OWNER TO erp_user;

--
-- Name: v_pd_fotos_det; Type: VIEW; Schema: sigco_rpt; Owner: erp_user
--

CREATE VIEW sigco_rpt.v_pd_fotos_det AS
 SELECT pf.id_registro AS foto_registro_id,
    p.id_registro AS prod_id,
    p.pd_id,
    h.fecha_pd,
    p.control_item_id,
    b.item_descripcion,
    p.etapa_id,
    et.etapa_nombre,
    pf.file_id,
    df.title AS file_title,
    df.filename_download,
    df.type AS file_type,
    df.filesize AS file_size,
    df.uploaded_on,
    pf.descripcion AS foto_descripcion,
    pf.orden AS foto_orden
   FROM (((((sigco.pd_produccion_fotos pf
     JOIN sigco.pd_produccion p ON ((p.id_registro = pf.produccion_id)))
     JOIN sigco.pd_header h ON (((h.pd_id)::text = (p.pd_id)::text)))
     LEFT JOIN sigco.boq_control b ON (((b.control_item_id)::text = (p.control_item_id)::text)))
     LEFT JOIN sigco.cat_etapas et ON (((et.etapa_id)::text = (p.etapa_id)::text)))
     LEFT JOIN public.directus_files df ON ((df.id = pf.file_id)));


ALTER VIEW sigco_rpt.v_pd_fotos_det OWNER TO erp_user;

--
-- Name: v_pd_hh_det; Type: VIEW; Schema: sigco_rpt; Owner: erp_user
--

CREATE VIEW sigco_rpt.v_pd_hh_det AS
 SELECT hh.id_registro AS hh_id,
    hh.pd_id,
    h.fecha_pd,
    hh.persona_nombre,
    hh.categoria_id,
    c.categoria_nombre,
    c.tipo AS categoria_tipo,
    hh.horas,
    hh.area_codigo,
    a.area_nombre,
    hh.observacion
   FROM (((sigco.pd_personal_hh hh
     JOIN sigco.pd_header h ON (((h.pd_id)::text = (hh.pd_id)::text)))
     LEFT JOIN sigco.cat_categorias_personal c ON (((c.categoria_id)::text = (hh.categoria_id)::text)))
     LEFT JOIN sigco.cat_areas_frentes a ON (((a.area_codigo)::text = (hh.area_codigo)::text)));


ALTER VIEW sigco_rpt.v_pd_hh_det OWNER TO erp_user;

--
-- Name: v_pd_hm_det; Type: VIEW; Schema: sigco_rpt; Owner: erp_user
--

CREATE VIEW sigco_rpt.v_pd_hm_det AS
 SELECT hm.id_registro AS hm_id,
    hm.pd_id,
    h.fecha_pd,
    hm.equipo_id,
    e.equipo_nombre,
    e.equipo_tipo,
    hm.horas_maquina,
    hm.area_codigo,
    a.area_nombre,
    hm.observacion
   FROM (((sigco.pd_equipos_hm hm
     JOIN sigco.pd_header h ON (((h.pd_id)::text = (hm.pd_id)::text)))
     LEFT JOIN sigco.cat_equipos e ON (((e.equipo_id)::text = (hm.equipo_id)::text)))
     LEFT JOIN sigco.cat_areas_frentes a ON (((a.area_codigo)::text = (hm.area_codigo)::text)));


ALTER VIEW sigco_rpt.v_pd_hm_det OWNER TO erp_user;

--
-- Name: v_pd_produccion_det; Type: VIEW; Schema: sigco_rpt; Owner: erp_user
--

CREATE VIEW sigco_rpt.v_pd_produccion_det AS
 SELECT p.id_registro AS prod_id,
    p.pd_id,
    h.fecha_pd,
    p.control_item_id,
    b.item_descripcion,
    p.etapa_id,
    e.etapa_nombre,
    e.orden AS etapa_orden,
    p.cantidad_dia,
    b.cantidad_base,
    u.unidad_tipo,
    p.hh_tarea,
    p.personas_tarea,
    p.ubicacion_referencia,
    p.observacion_linea,
    b.area_codigo,
    a.area_nombre,
    b.familia_id,
    f.familia_nombre,
    b.wbs_id,
    w.wbs_nombre
   FROM (((((((sigco.pd_produccion p
     JOIN sigco.pd_header h ON (((h.pd_id)::text = (p.pd_id)::text)))
     LEFT JOIN sigco.boq_control b ON (((b.control_item_id)::text = (p.control_item_id)::text)))
     LEFT JOIN sigco.cat_etapas e ON (((e.etapa_id)::text = (p.etapa_id)::text)))
     LEFT JOIN sigco.cat_unidades u ON (((u.unidad_id)::text = (b.unidad_id)::text)))
     LEFT JOIN sigco.cat_familias f ON (((f.familia_id)::text = (b.familia_id)::text)))
     LEFT JOIN sigco.cat_areas_frentes a ON (((a.area_codigo)::text = (b.area_codigo)::text)))
     LEFT JOIN sigco.wbs w ON (((w.wbs_id)::text = (b.wbs_id)::text)));


ALTER VIEW sigco_rpt.v_pd_produccion_det OWNER TO erp_user;

--
-- Name: v_pd_restricciones_det; Type: VIEW; Schema: sigco_rpt; Owner: erp_user
--

CREATE VIEW sigco_rpt.v_pd_restricciones_det AS
 SELECT r.id_registro AS restriccion_registro_id,
    r.pd_id,
    h.fecha_pd,
    r.restriccion_id,
    cr.categoria AS restriccion_categoria,
    cr.restriccion_nombre,
    cr.restriccion_definicion,
    r.horas_impacto,
    r.area_codigo,
    a.area_nombre,
    r.descripcion_evento,
    r.accion_tomada
   FROM (((sigco.pd_restricciones r
     JOIN sigco.pd_header h ON (((h.pd_id)::text = (r.pd_id)::text)))
     LEFT JOIN sigco.cat_restricciones cr ON (((cr.restriccion_id)::text = (r.restriccion_id)::text)))
     LEFT JOIN sigco.cat_areas_frentes a ON (((a.area_codigo)::text = (r.area_codigo)::text)));


ALTER VIEW sigco_rpt.v_pd_restricciones_det OWNER TO erp_user;

--
-- Name: v_pd_restricciones_kpi; Type: VIEW; Schema: sigco_rpt; Owner: erp_user
--

CREATE VIEW sigco_rpt.v_pd_restricciones_kpi AS
 SELECT h.pd_id,
    h.fecha_pd,
    (sum(COALESCE(r.horas_impacto, (0)::numeric)))::numeric(12,2) AS horas_improductivas
   FROM (sigco.pd_header h
     LEFT JOIN sigco.pd_restricciones r ON (((r.pd_id)::text = (h.pd_id)::text)))
  GROUP BY h.pd_id, h.fecha_pd
  ORDER BY h.fecha_pd DESC;


ALTER VIEW sigco_rpt.v_pd_restricciones_kpi OWNER TO erp_user;

--
-- Name: v_pd_restricciones_resumen; Type: VIEW; Schema: sigco_rpt; Owner: erp_user
--

CREATE VIEW sigco_rpt.v_pd_restricciones_resumen AS
 SELECT r.pd_id,
    h.fecha_pd,
    COALESCE(r.area_codigo, 'N/A'::character varying) AS area_codigo,
    a.area_nombre,
    COALESCE(cr.categoria, 'Sin categoría'::character varying) AS restriccion_categoria,
    r.restriccion_id,
    cr.restriccion_nombre,
    (sum(COALESCE(r.horas_impacto, (0)::numeric)))::numeric(12,2) AS horas_impacto_total,
    count(*) AS eventos
   FROM (((sigco.pd_restricciones r
     JOIN sigco.pd_header h ON (((h.pd_id)::text = (r.pd_id)::text)))
     LEFT JOIN sigco.cat_restricciones cr ON (((cr.restriccion_id)::text = (r.restriccion_id)::text)))
     LEFT JOIN sigco.cat_areas_frentes a ON (((a.area_codigo)::text = (r.area_codigo)::text)))
  GROUP BY r.pd_id, h.fecha_pd, r.area_codigo, a.area_nombre, cr.categoria, r.restriccion_id, cr.restriccion_nombre
  ORDER BY h.fecha_pd DESC, r.pd_id;


ALTER VIEW sigco_rpt.v_pd_restricciones_resumen OWNER TO erp_user;

--
-- Name: departamentos id; Type: DEFAULT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.departamentos ALTER COLUMN id SET DEFAULT nextval('public.departamentos_id_seq'::regclass);


--
-- Name: directus_activity id; Type: DEFAULT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_activity ALTER COLUMN id SET DEFAULT nextval('public.directus_activity_id_seq'::regclass);


--
-- Name: directus_fields id; Type: DEFAULT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_fields ALTER COLUMN id SET DEFAULT nextval('public.directus_fields_id_seq'::regclass);


--
-- Name: directus_notifications id; Type: DEFAULT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_notifications ALTER COLUMN id SET DEFAULT nextval('public.directus_notifications_id_seq'::regclass);


--
-- Name: directus_permissions id; Type: DEFAULT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_permissions ALTER COLUMN id SET DEFAULT nextval('public.directus_permissions_id_seq'::regclass);


--
-- Name: directus_presets id; Type: DEFAULT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_presets ALTER COLUMN id SET DEFAULT nextval('public.directus_presets_id_seq'::regclass);


--
-- Name: directus_relations id; Type: DEFAULT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_relations ALTER COLUMN id SET DEFAULT nextval('public.directus_relations_id_seq'::regclass);


--
-- Name: directus_revisions id; Type: DEFAULT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_revisions ALTER COLUMN id SET DEFAULT nextval('public.directus_revisions_id_seq'::regclass);


--
-- Name: directus_settings id; Type: DEFAULT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_settings ALTER COLUMN id SET DEFAULT nextval('public.directus_settings_id_seq'::regclass);


--
-- Name: directus_webhooks id; Type: DEFAULT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_webhooks ALTER COLUMN id SET DEFAULT nextval('public.directus_webhooks_id_seq'::regclass);


--
-- Name: organizaciones id; Type: DEFAULT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.organizaciones ALTER COLUMN id SET DEFAULT nextval('public.organizaciones_id_seq'::regclass);


--
-- Name: proyecto_miembros id; Type: DEFAULT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.proyecto_miembros ALTER COLUMN id SET DEFAULT nextval('public.proyecto_miembros_id_seq'::regclass);


--
-- Name: proyectos id; Type: DEFAULT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.proyectos ALTER COLUMN id SET DEFAULT nextval('public.proyectos_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: tareas id; Type: DEFAULT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.tareas ALTER COLUMN id SET DEFAULT nextval('public.tareas_id_seq'::regclass);


--
-- Name: usuario_departamentos id; Type: DEFAULT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.usuario_departamentos ALTER COLUMN id SET DEFAULT nextval('public.usuario_departamentos_id_seq'::regclass);


--
-- Name: usuario_roles id; Type: DEFAULT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.usuario_roles ALTER COLUMN id SET DEFAULT nextval('public.usuario_roles_id_seq'::regclass);


--
-- Name: usuarios id; Type: DEFAULT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.usuarios ALTER COLUMN id SET DEFAULT nextval('public.usuarios_id_seq'::regclass);


--
-- Name: pd_equipos_hm id_registro; Type: DEFAULT; Schema: sigco; Owner: erp_user
--

ALTER TABLE ONLY sigco.pd_equipos_hm ALTER COLUMN id_registro SET DEFAULT nextval('sigco.pd_equipos_hm_id_registro_seq'::regclass);


--
-- Name: pd_personal_hh id_registro; Type: DEFAULT; Schema: sigco; Owner: erp_user
--

ALTER TABLE ONLY sigco.pd_personal_hh ALTER COLUMN id_registro SET DEFAULT nextval('sigco.pd_personal_hh_id_registro_seq'::regclass);


--
-- Name: pd_produccion id_registro; Type: DEFAULT; Schema: sigco; Owner: erp_user
--

ALTER TABLE ONLY sigco.pd_produccion ALTER COLUMN id_registro SET DEFAULT nextval('sigco.pd_produccion_id_registro_seq'::regclass);


--
-- Name: pd_produccion_fotos id_registro; Type: DEFAULT; Schema: sigco; Owner: erp_user
--

ALTER TABLE ONLY sigco.pd_produccion_fotos ALTER COLUMN id_registro SET DEFAULT nextval('sigco.pd_produccion_fotos_id_registro_seq'::regclass);


--
-- Name: pd_restricciones id_registro; Type: DEFAULT; Schema: sigco; Owner: erp_user
--

ALTER TABLE ONLY sigco.pd_restricciones ALTER COLUMN id_registro SET DEFAULT nextval('sigco.pd_restricciones_id_registro_seq'::regclass);


--
-- Name: departamentos departamentos_pkey; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.departamentos
    ADD CONSTRAINT departamentos_pkey PRIMARY KEY (id);


--
-- Name: directus_activity directus_activity_pkey; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_activity
    ADD CONSTRAINT directus_activity_pkey PRIMARY KEY (id);


--
-- Name: directus_collections directus_collections_pkey; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_collections
    ADD CONSTRAINT directus_collections_pkey PRIMARY KEY (collection);


--
-- Name: directus_dashboards directus_dashboards_pkey; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_dashboards
    ADD CONSTRAINT directus_dashboards_pkey PRIMARY KEY (id);


--
-- Name: directus_extensions directus_extensions_pkey; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_extensions
    ADD CONSTRAINT directus_extensions_pkey PRIMARY KEY (id);


--
-- Name: directus_fields directus_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_fields
    ADD CONSTRAINT directus_fields_pkey PRIMARY KEY (id);


--
-- Name: directus_files directus_files_pkey; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_files
    ADD CONSTRAINT directus_files_pkey PRIMARY KEY (id);


--
-- Name: directus_flows directus_flows_operation_unique; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_flows
    ADD CONSTRAINT directus_flows_operation_unique UNIQUE (operation);


--
-- Name: directus_flows directus_flows_pkey; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_flows
    ADD CONSTRAINT directus_flows_pkey PRIMARY KEY (id);


--
-- Name: directus_folders directus_folders_pkey; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_folders
    ADD CONSTRAINT directus_folders_pkey PRIMARY KEY (id);


--
-- Name: directus_migrations directus_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_migrations
    ADD CONSTRAINT directus_migrations_pkey PRIMARY KEY (version);


--
-- Name: directus_notifications directus_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_notifications
    ADD CONSTRAINT directus_notifications_pkey PRIMARY KEY (id);


--
-- Name: directus_operations directus_operations_pkey; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_operations
    ADD CONSTRAINT directus_operations_pkey PRIMARY KEY (id);


--
-- Name: directus_operations directus_operations_reject_unique; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_operations
    ADD CONSTRAINT directus_operations_reject_unique UNIQUE (reject);


--
-- Name: directus_operations directus_operations_resolve_unique; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_operations
    ADD CONSTRAINT directus_operations_resolve_unique UNIQUE (resolve);


--
-- Name: directus_panels directus_panels_pkey; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_panels
    ADD CONSTRAINT directus_panels_pkey PRIMARY KEY (id);


--
-- Name: directus_permissions directus_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_permissions
    ADD CONSTRAINT directus_permissions_pkey PRIMARY KEY (id);


--
-- Name: directus_presets directus_presets_pkey; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_presets
    ADD CONSTRAINT directus_presets_pkey PRIMARY KEY (id);


--
-- Name: directus_relations directus_relations_pkey; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_relations
    ADD CONSTRAINT directus_relations_pkey PRIMARY KEY (id);


--
-- Name: directus_revisions directus_revisions_pkey; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_revisions
    ADD CONSTRAINT directus_revisions_pkey PRIMARY KEY (id);


--
-- Name: directus_roles directus_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_roles
    ADD CONSTRAINT directus_roles_pkey PRIMARY KEY (id);


--
-- Name: directus_sessions directus_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_sessions
    ADD CONSTRAINT directus_sessions_pkey PRIMARY KEY (token);


--
-- Name: directus_settings directus_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_settings
    ADD CONSTRAINT directus_settings_pkey PRIMARY KEY (id);


--
-- Name: directus_shares directus_shares_pkey; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_shares
    ADD CONSTRAINT directus_shares_pkey PRIMARY KEY (id);


--
-- Name: directus_translations directus_translations_pkey; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_translations
    ADD CONSTRAINT directus_translations_pkey PRIMARY KEY (id);


--
-- Name: directus_users directus_users_email_unique; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_users
    ADD CONSTRAINT directus_users_email_unique UNIQUE (email);


--
-- Name: directus_users directus_users_external_identifier_unique; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_users
    ADD CONSTRAINT directus_users_external_identifier_unique UNIQUE (external_identifier);


--
-- Name: directus_users directus_users_pkey; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_users
    ADD CONSTRAINT directus_users_pkey PRIMARY KEY (id);


--
-- Name: directus_users directus_users_token_unique; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_users
    ADD CONSTRAINT directus_users_token_unique UNIQUE (token);


--
-- Name: directus_versions directus_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_versions
    ADD CONSTRAINT directus_versions_pkey PRIMARY KEY (id);


--
-- Name: directus_webhooks directus_webhooks_pkey; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_webhooks
    ADD CONSTRAINT directus_webhooks_pkey PRIMARY KEY (id);


--
-- Name: organizaciones organizaciones_pkey; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.organizaciones
    ADD CONSTRAINT organizaciones_pkey PRIMARY KEY (id);


--
-- Name: proyecto_miembros proyecto_miembros_pkey; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.proyecto_miembros
    ADD CONSTRAINT proyecto_miembros_pkey PRIMARY KEY (id);


--
-- Name: proyecto_miembros proyecto_miembros_proyecto_id_usuario_id_key; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.proyecto_miembros
    ADD CONSTRAINT proyecto_miembros_proyecto_id_usuario_id_key UNIQUE (proyecto_id, usuario_id);


--
-- Name: proyectos proyectos_codigo_key; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.proyectos
    ADD CONSTRAINT proyectos_codigo_key UNIQUE (codigo);


--
-- Name: proyectos proyectos_pkey; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.proyectos
    ADD CONSTRAINT proyectos_pkey PRIMARY KEY (id);


--
-- Name: roles roles_nombre_key; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_nombre_key UNIQUE (nombre);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: tareas tareas_pkey; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.tareas
    ADD CONSTRAINT tareas_pkey PRIMARY KEY (id);


--
-- Name: usuario_departamentos usuario_departamentos_pkey; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.usuario_departamentos
    ADD CONSTRAINT usuario_departamentos_pkey PRIMARY KEY (id);


--
-- Name: usuario_roles usuario_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.usuario_roles
    ADD CONSTRAINT usuario_roles_pkey PRIMARY KEY (id);


--
-- Name: usuarios usuarios_email_key; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_email_key UNIQUE (email);


--
-- Name: usuarios usuarios_pkey; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_pkey PRIMARY KEY (id);


--
-- Name: boq_control boq_control_pkey; Type: CONSTRAINT; Schema: sigco; Owner: erp_user
--

ALTER TABLE ONLY sigco.boq_control
    ADD CONSTRAINT boq_control_pkey PRIMARY KEY (control_item_id);


--
-- Name: cat_areas_frentes cat_areas_frentes_pkey; Type: CONSTRAINT; Schema: sigco; Owner: erp_user
--

ALTER TABLE ONLY sigco.cat_areas_frentes
    ADD CONSTRAINT cat_areas_frentes_pkey PRIMARY KEY (area_codigo);


--
-- Name: cat_categorias_personal cat_categorias_personal_pkey; Type: CONSTRAINT; Schema: sigco; Owner: erp_user
--

ALTER TABLE ONLY sigco.cat_categorias_personal
    ADD CONSTRAINT cat_categorias_personal_pkey PRIMARY KEY (categoria_id);


--
-- Name: cat_equipos cat_equipos_pkey; Type: CONSTRAINT; Schema: sigco; Owner: erp_user
--

ALTER TABLE ONLY sigco.cat_equipos
    ADD CONSTRAINT cat_equipos_pkey PRIMARY KEY (equipo_id);


--
-- Name: cat_etapas cat_etapas_pkey; Type: CONSTRAINT; Schema: sigco; Owner: erp_user
--

ALTER TABLE ONLY sigco.cat_etapas
    ADD CONSTRAINT cat_etapas_pkey PRIMARY KEY (etapa_id);


--
-- Name: cat_familias cat_familias_pkey; Type: CONSTRAINT; Schema: sigco; Owner: erp_user
--

ALTER TABLE ONLY sigco.cat_familias
    ADD CONSTRAINT cat_familias_pkey PRIMARY KEY (familia_id);


--
-- Name: cat_restricciones cat_restricciones_pkey; Type: CONSTRAINT; Schema: sigco; Owner: erp_user
--

ALTER TABLE ONLY sigco.cat_restricciones
    ADD CONSTRAINT cat_restricciones_pkey PRIMARY KEY (restriccion_id);


--
-- Name: cat_unidades cat_unidades_pkey; Type: CONSTRAINT; Schema: sigco; Owner: erp_user
--

ALTER TABLE ONLY sigco.cat_unidades
    ADD CONSTRAINT cat_unidades_pkey PRIMARY KEY (unidad_id);


--
-- Name: pd_equipos_hm pd_equipos_hm_pkey; Type: CONSTRAINT; Schema: sigco; Owner: erp_user
--

ALTER TABLE ONLY sigco.pd_equipos_hm
    ADD CONSTRAINT pd_equipos_hm_pkey PRIMARY KEY (id_registro);


--
-- Name: pd_header pd_header_pkey; Type: CONSTRAINT; Schema: sigco; Owner: erp_user
--

ALTER TABLE ONLY sigco.pd_header
    ADD CONSTRAINT pd_header_pkey PRIMARY KEY (pd_id);


--
-- Name: pd_personal_hh pd_personal_hh_pkey; Type: CONSTRAINT; Schema: sigco; Owner: erp_user
--

ALTER TABLE ONLY sigco.pd_personal_hh
    ADD CONSTRAINT pd_personal_hh_pkey PRIMARY KEY (id_registro);


--
-- Name: pd_produccion_fotos pd_produccion_fotos_pkey; Type: CONSTRAINT; Schema: sigco; Owner: erp_user
--

ALTER TABLE ONLY sigco.pd_produccion_fotos
    ADD CONSTRAINT pd_produccion_fotos_pkey PRIMARY KEY (id_registro);


--
-- Name: pd_produccion pd_produccion_pkey; Type: CONSTRAINT; Schema: sigco; Owner: erp_user
--

ALTER TABLE ONLY sigco.pd_produccion
    ADD CONSTRAINT pd_produccion_pkey PRIMARY KEY (id_registro);


--
-- Name: pd_restricciones pd_restricciones_pkey; Type: CONSTRAINT; Schema: sigco; Owner: erp_user
--

ALTER TABLE ONLY sigco.pd_restricciones
    ADD CONSTRAINT pd_restricciones_pkey PRIMARY KEY (id_registro);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: sigco; Owner: erp_user
--

ALTER TABLE ONLY sigco.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (project_id);


--
-- Name: pd_produccion uq_pd_prod; Type: CONSTRAINT; Schema: sigco; Owner: erp_user
--

ALTER TABLE ONLY sigco.pd_produccion
    ADD CONSTRAINT uq_pd_prod UNIQUE (pd_id, control_item_id, etapa_id);


--
-- Name: wbs wbs_pkey; Type: CONSTRAINT; Schema: sigco; Owner: erp_user
--

ALTER TABLE ONLY sigco.wbs
    ADD CONSTRAINT wbs_pkey PRIMARY KEY (wbs_id);


--
-- Name: op_project_map op_project_map_pkey; Type: CONSTRAINT; Schema: sigco_int; Owner: erp_user
--

ALTER TABLE ONLY sigco_int.op_project_map
    ADD CONSTRAINT op_project_map_pkey PRIMARY KEY (sigco_project_id);


--
-- Name: op_time_entry_dedupe op_time_entry_dedupe_pkey; Type: CONSTRAINT; Schema: sigco_int; Owner: erp_user
--

ALTER TABLE ONLY sigco_int.op_time_entry_dedupe
    ADD CONSTRAINT op_time_entry_dedupe_pkey PRIMARY KEY (dedupe_key);


--
-- Name: op_wp_map op_wp_map_pkey; Type: CONSTRAINT; Schema: sigco_int; Owner: erp_user
--

ALTER TABLE ONLY sigco_int.op_wp_map
    ADD CONSTRAINT op_wp_map_pkey PRIMARY KEY (sigco_project_id, wbs_id);


--
-- Name: idx_deptos_activos; Type: INDEX; Schema: public; Owner: erp_user
--

CREATE INDEX idx_deptos_activos ON public.departamentos USING btree (id) WHERE (deleted_at IS NULL);


--
-- Name: idx_orgs_activas; Type: INDEX; Schema: public; Owner: erp_user
--

CREATE INDEX idx_orgs_activas ON public.organizaciones USING btree (id) WHERE (deleted_at IS NULL);


--
-- Name: idx_proy_codigo; Type: INDEX; Schema: public; Owner: erp_user
--

CREATE INDEX idx_proy_codigo ON public.proyectos USING btree (codigo) WHERE (deleted_at IS NULL);


--
-- Name: idx_proy_estado; Type: INDEX; Schema: public; Owner: erp_user
--

CREATE INDEX idx_proy_estado ON public.proyectos USING btree (estado) WHERE (deleted_at IS NULL);


--
-- Name: idx_proyecto_miembros_proyecto; Type: INDEX; Schema: public; Owner: erp_user
--

CREATE INDEX idx_proyecto_miembros_proyecto ON public.proyecto_miembros USING btree (proyecto_id);


--
-- Name: idx_proyecto_miembros_usuario; Type: INDEX; Schema: public; Owner: erp_user
--

CREATE INDEX idx_proyecto_miembros_usuario ON public.proyecto_miembros USING btree (usuario_id);


--
-- Name: idx_tareas_estado; Type: INDEX; Schema: public; Owner: erp_user
--

CREATE INDEX idx_tareas_estado ON public.tareas USING btree (estado) WHERE (deleted_at IS NULL);


--
-- Name: idx_tareas_proyecto; Type: INDEX; Schema: public; Owner: erp_user
--

CREATE INDEX idx_tareas_proyecto ON public.tareas USING btree (proyecto_id) WHERE (deleted_at IS NULL);


--
-- Name: idx_usuario_deptos_depto; Type: INDEX; Schema: public; Owner: erp_user
--

CREATE INDEX idx_usuario_deptos_depto ON public.usuario_departamentos USING btree (departamento_id);


--
-- Name: idx_usuario_deptos_usuario; Type: INDEX; Schema: public; Owner: erp_user
--

CREATE INDEX idx_usuario_deptos_usuario ON public.usuario_departamentos USING btree (usuario_id);


--
-- Name: idx_usuario_roles_rol; Type: INDEX; Schema: public; Owner: erp_user
--

CREATE INDEX idx_usuario_roles_rol ON public.usuario_roles USING btree (rol_id);


--
-- Name: idx_usuario_roles_usuario; Type: INDEX; Schema: public; Owner: erp_user
--

CREATE INDEX idx_usuario_roles_usuario ON public.usuario_roles USING btree (usuario_id);


--
-- Name: idx_usuarios_activo; Type: INDEX; Schema: public; Owner: erp_user
--

CREATE INDEX idx_usuarios_activo ON public.usuarios USING btree (activo) WHERE (deleted_at IS NULL);


--
-- Name: idx_usuarios_email; Type: INDEX; Schema: public; Owner: erp_user
--

CREATE INDEX idx_usuarios_email ON public.usuarios USING btree (email);


--
-- Name: uq_usuario_roles_usuario_rol; Type: INDEX; Schema: public; Owner: erp_user
--

CREATE UNIQUE INDEX uq_usuario_roles_usuario_rol ON public.usuario_roles USING btree (usuario_id, rol_id);


--
-- Name: idx_boq_area; Type: INDEX; Schema: sigco; Owner: erp_user
--

CREATE INDEX idx_boq_area ON sigco.boq_control USING btree (area_codigo);


--
-- Name: idx_boq_wbs; Type: INDEX; Schema: sigco; Owner: erp_user
--

CREATE INDEX idx_boq_wbs ON sigco.boq_control USING btree (wbs_id);


--
-- Name: idx_pd_header_fecha; Type: INDEX; Schema: sigco; Owner: erp_user
--

CREATE INDEX idx_pd_header_fecha ON sigco.pd_header USING btree (fecha_pd);


--
-- Name: idx_pd_hh_pd; Type: INDEX; Schema: sigco; Owner: erp_user
--

CREATE INDEX idx_pd_hh_pd ON sigco.pd_personal_hh USING btree (pd_id);


--
-- Name: idx_pd_hm_pd; Type: INDEX; Schema: sigco; Owner: erp_user
--

CREATE INDEX idx_pd_hm_pd ON sigco.pd_equipos_hm USING btree (pd_id);


--
-- Name: idx_pd_prod_foto_produccion; Type: INDEX; Schema: sigco; Owner: erp_user
--

CREATE INDEX idx_pd_prod_foto_produccion ON sigco.pd_produccion_fotos USING btree (produccion_id);


--
-- Name: idx_pd_prod_fotos_prod; Type: INDEX; Schema: sigco; Owner: erp_user
--

CREATE INDEX idx_pd_prod_fotos_prod ON sigco.pd_produccion_fotos USING btree (produccion_id);


--
-- Name: idx_pd_prod_pd; Type: INDEX; Schema: sigco; Owner: erp_user
--

CREATE INDEX idx_pd_prod_pd ON sigco.pd_produccion USING btree (pd_id);


--
-- Name: idx_pd_res_area; Type: INDEX; Schema: sigco; Owner: erp_user
--

CREATE INDEX idx_pd_res_area ON sigco.pd_restricciones USING btree (area_codigo);


--
-- Name: idx_pd_res_pd; Type: INDEX; Schema: sigco; Owner: erp_user
--

CREATE INDEX idx_pd_res_pd ON sigco.pd_restricciones USING btree (pd_id);


--
-- Name: idx_pd_res_restr; Type: INDEX; Schema: sigco; Owner: erp_user
--

CREATE INDEX idx_pd_res_restr ON sigco.pd_restricciones USING btree (restriccion_id);


--
-- Name: idx_sigco_boq_project_id; Type: INDEX; Schema: sigco; Owner: erp_user
--

CREATE INDEX idx_sigco_boq_project_id ON sigco.boq_control USING btree (project_id);


--
-- Name: idx_sigco_pd_header_project_id; Type: INDEX; Schema: sigco; Owner: erp_user
--

CREATE INDEX idx_sigco_pd_header_project_id ON sigco.pd_header USING btree (project_id);


--
-- Name: idx_sigco_wbs_project_id; Type: INDEX; Schema: sigco; Owner: erp_user
--

CREATE INDEX idx_sigco_wbs_project_id ON sigco.wbs USING btree (project_id);


--
-- Name: idx_op_wp_map_wp_id; Type: INDEX; Schema: sigco_int; Owner: erp_user
--

CREATE INDEX idx_op_wp_map_wp_id ON sigco_int.op_wp_map USING btree (op_work_package_id);


--
-- Name: pd_header trg_pd_header_estado_audit; Type: TRIGGER; Schema: sigco; Owner: erp_user
--

CREATE TRIGGER trg_pd_header_estado_audit BEFORE UPDATE OF estado ON sigco.pd_header FOR EACH ROW EXECUTE FUNCTION sigco.fn_pd_header_estado_audit();


--
-- Name: departamentos departamentos_departamento_padre_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.departamentos
    ADD CONSTRAINT departamentos_departamento_padre_id_fkey FOREIGN KEY (departamento_padre_id) REFERENCES public.departamentos(id);


--
-- Name: departamentos departamentos_organizacion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.departamentos
    ADD CONSTRAINT departamentos_organizacion_id_fkey FOREIGN KEY (organizacion_id) REFERENCES public.organizaciones(id) ON DELETE CASCADE;


--
-- Name: departamentos departamentos_responsable_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.departamentos
    ADD CONSTRAINT departamentos_responsable_id_fkey FOREIGN KEY (responsable_id) REFERENCES public.usuarios(id);


--
-- Name: directus_collections directus_collections_group_foreign; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_collections
    ADD CONSTRAINT directus_collections_group_foreign FOREIGN KEY ("group") REFERENCES public.directus_collections(collection);


--
-- Name: directus_dashboards directus_dashboards_user_created_foreign; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_dashboards
    ADD CONSTRAINT directus_dashboards_user_created_foreign FOREIGN KEY (user_created) REFERENCES public.directus_users(id) ON DELETE SET NULL;


--
-- Name: directus_files directus_files_folder_foreign; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_files
    ADD CONSTRAINT directus_files_folder_foreign FOREIGN KEY (folder) REFERENCES public.directus_folders(id) ON DELETE SET NULL;


--
-- Name: directus_files directus_files_modified_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_files
    ADD CONSTRAINT directus_files_modified_by_foreign FOREIGN KEY (modified_by) REFERENCES public.directus_users(id);


--
-- Name: directus_files directus_files_uploaded_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_files
    ADD CONSTRAINT directus_files_uploaded_by_foreign FOREIGN KEY (uploaded_by) REFERENCES public.directus_users(id);


--
-- Name: directus_flows directus_flows_user_created_foreign; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_flows
    ADD CONSTRAINT directus_flows_user_created_foreign FOREIGN KEY (user_created) REFERENCES public.directus_users(id) ON DELETE SET NULL;


--
-- Name: directus_folders directus_folders_parent_foreign; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_folders
    ADD CONSTRAINT directus_folders_parent_foreign FOREIGN KEY (parent) REFERENCES public.directus_folders(id);


--
-- Name: directus_notifications directus_notifications_recipient_foreign; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_notifications
    ADD CONSTRAINT directus_notifications_recipient_foreign FOREIGN KEY (recipient) REFERENCES public.directus_users(id) ON DELETE CASCADE;


--
-- Name: directus_notifications directus_notifications_sender_foreign; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_notifications
    ADD CONSTRAINT directus_notifications_sender_foreign FOREIGN KEY (sender) REFERENCES public.directus_users(id);


--
-- Name: directus_operations directus_operations_flow_foreign; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_operations
    ADD CONSTRAINT directus_operations_flow_foreign FOREIGN KEY (flow) REFERENCES public.directus_flows(id) ON DELETE CASCADE;


--
-- Name: directus_operations directus_operations_reject_foreign; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_operations
    ADD CONSTRAINT directus_operations_reject_foreign FOREIGN KEY (reject) REFERENCES public.directus_operations(id);


--
-- Name: directus_operations directus_operations_resolve_foreign; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_operations
    ADD CONSTRAINT directus_operations_resolve_foreign FOREIGN KEY (resolve) REFERENCES public.directus_operations(id);


--
-- Name: directus_operations directus_operations_user_created_foreign; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_operations
    ADD CONSTRAINT directus_operations_user_created_foreign FOREIGN KEY (user_created) REFERENCES public.directus_users(id) ON DELETE SET NULL;


--
-- Name: directus_panels directus_panels_dashboard_foreign; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_panels
    ADD CONSTRAINT directus_panels_dashboard_foreign FOREIGN KEY (dashboard) REFERENCES public.directus_dashboards(id) ON DELETE CASCADE;


--
-- Name: directus_panels directus_panels_user_created_foreign; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_panels
    ADD CONSTRAINT directus_panels_user_created_foreign FOREIGN KEY (user_created) REFERENCES public.directus_users(id) ON DELETE SET NULL;


--
-- Name: directus_permissions directus_permissions_role_foreign; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_permissions
    ADD CONSTRAINT directus_permissions_role_foreign FOREIGN KEY (role) REFERENCES public.directus_roles(id) ON DELETE CASCADE;


--
-- Name: directus_presets directus_presets_role_foreign; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_presets
    ADD CONSTRAINT directus_presets_role_foreign FOREIGN KEY (role) REFERENCES public.directus_roles(id) ON DELETE CASCADE;


--
-- Name: directus_presets directus_presets_user_foreign; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_presets
    ADD CONSTRAINT directus_presets_user_foreign FOREIGN KEY ("user") REFERENCES public.directus_users(id) ON DELETE CASCADE;


--
-- Name: directus_revisions directus_revisions_activity_foreign; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_revisions
    ADD CONSTRAINT directus_revisions_activity_foreign FOREIGN KEY (activity) REFERENCES public.directus_activity(id) ON DELETE CASCADE;


--
-- Name: directus_revisions directus_revisions_parent_foreign; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_revisions
    ADD CONSTRAINT directus_revisions_parent_foreign FOREIGN KEY (parent) REFERENCES public.directus_revisions(id);


--
-- Name: directus_revisions directus_revisions_version_foreign; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_revisions
    ADD CONSTRAINT directus_revisions_version_foreign FOREIGN KEY (version) REFERENCES public.directus_versions(id) ON DELETE CASCADE;


--
-- Name: directus_sessions directus_sessions_share_foreign; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_sessions
    ADD CONSTRAINT directus_sessions_share_foreign FOREIGN KEY (share) REFERENCES public.directus_shares(id) ON DELETE CASCADE;


--
-- Name: directus_sessions directus_sessions_user_foreign; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_sessions
    ADD CONSTRAINT directus_sessions_user_foreign FOREIGN KEY ("user") REFERENCES public.directus_users(id) ON DELETE CASCADE;


--
-- Name: directus_settings directus_settings_project_logo_foreign; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_settings
    ADD CONSTRAINT directus_settings_project_logo_foreign FOREIGN KEY (project_logo) REFERENCES public.directus_files(id);


--
-- Name: directus_settings directus_settings_public_background_foreign; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_settings
    ADD CONSTRAINT directus_settings_public_background_foreign FOREIGN KEY (public_background) REFERENCES public.directus_files(id);


--
-- Name: directus_settings directus_settings_public_favicon_foreign; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_settings
    ADD CONSTRAINT directus_settings_public_favicon_foreign FOREIGN KEY (public_favicon) REFERENCES public.directus_files(id);


--
-- Name: directus_settings directus_settings_public_foreground_foreign; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_settings
    ADD CONSTRAINT directus_settings_public_foreground_foreign FOREIGN KEY (public_foreground) REFERENCES public.directus_files(id);


--
-- Name: directus_settings directus_settings_public_registration_role_foreign; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_settings
    ADD CONSTRAINT directus_settings_public_registration_role_foreign FOREIGN KEY (public_registration_role) REFERENCES public.directus_roles(id) ON DELETE SET NULL;


--
-- Name: directus_settings directus_settings_storage_default_folder_foreign; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_settings
    ADD CONSTRAINT directus_settings_storage_default_folder_foreign FOREIGN KEY (storage_default_folder) REFERENCES public.directus_folders(id) ON DELETE SET NULL;


--
-- Name: directus_shares directus_shares_collection_foreign; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_shares
    ADD CONSTRAINT directus_shares_collection_foreign FOREIGN KEY (collection) REFERENCES public.directus_collections(collection) ON DELETE CASCADE;


--
-- Name: directus_shares directus_shares_role_foreign; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_shares
    ADD CONSTRAINT directus_shares_role_foreign FOREIGN KEY (role) REFERENCES public.directus_roles(id) ON DELETE CASCADE;


--
-- Name: directus_shares directus_shares_user_created_foreign; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_shares
    ADD CONSTRAINT directus_shares_user_created_foreign FOREIGN KEY (user_created) REFERENCES public.directus_users(id) ON DELETE SET NULL;


--
-- Name: directus_users directus_users_role_foreign; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_users
    ADD CONSTRAINT directus_users_role_foreign FOREIGN KEY (role) REFERENCES public.directus_roles(id) ON DELETE SET NULL;


--
-- Name: directus_versions directus_versions_collection_foreign; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_versions
    ADD CONSTRAINT directus_versions_collection_foreign FOREIGN KEY (collection) REFERENCES public.directus_collections(collection) ON DELETE CASCADE;


--
-- Name: directus_versions directus_versions_user_created_foreign; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_versions
    ADD CONSTRAINT directus_versions_user_created_foreign FOREIGN KEY (user_created) REFERENCES public.directus_users(id) ON DELETE SET NULL;


--
-- Name: directus_versions directus_versions_user_updated_foreign; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_versions
    ADD CONSTRAINT directus_versions_user_updated_foreign FOREIGN KEY (user_updated) REFERENCES public.directus_users(id);


--
-- Name: directus_webhooks directus_webhooks_migrated_flow_foreign; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.directus_webhooks
    ADD CONSTRAINT directus_webhooks_migrated_flow_foreign FOREIGN KEY (migrated_flow) REFERENCES public.directus_flows(id) ON DELETE SET NULL;


--
-- Name: proyecto_miembros proyecto_miembros_proyecto_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.proyecto_miembros
    ADD CONSTRAINT proyecto_miembros_proyecto_id_fkey FOREIGN KEY (proyecto_id) REFERENCES public.proyectos(id) ON DELETE CASCADE;


--
-- Name: proyecto_miembros proyecto_miembros_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.proyecto_miembros
    ADD CONSTRAINT proyecto_miembros_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuarios(id) ON DELETE CASCADE;


--
-- Name: proyectos proyectos_gerente_proyecto_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.proyectos
    ADD CONSTRAINT proyectos_gerente_proyecto_id_fkey FOREIGN KEY (gerente_proyecto_id) REFERENCES public.usuarios(id) ON DELETE SET NULL;


--
-- Name: proyectos proyectos_organizacion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.proyectos
    ADD CONSTRAINT proyectos_organizacion_id_fkey FOREIGN KEY (organizacion_id) REFERENCES public.organizaciones(id) ON DELETE SET NULL;


--
-- Name: proyectos proyectos_sponsor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.proyectos
    ADD CONSTRAINT proyectos_sponsor_id_fkey FOREIGN KEY (sponsor_id) REFERENCES public.usuarios(id) ON DELETE SET NULL;


--
-- Name: tareas tareas_asignado_a_fkey; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.tareas
    ADD CONSTRAINT tareas_asignado_a_fkey FOREIGN KEY (asignado_a) REFERENCES public.usuarios(id) ON DELETE SET NULL;


--
-- Name: tareas tareas_proyecto_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.tareas
    ADD CONSTRAINT tareas_proyecto_id_fkey FOREIGN KEY (proyecto_id) REFERENCES public.proyectos(id) ON DELETE CASCADE;


--
-- Name: usuario_departamentos usuario_departamentos_departamento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.usuario_departamentos
    ADD CONSTRAINT usuario_departamentos_departamento_id_fkey FOREIGN KEY (departamento_id) REFERENCES public.departamentos(id) ON DELETE CASCADE;


--
-- Name: usuario_departamentos usuario_departamentos_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.usuario_departamentos
    ADD CONSTRAINT usuario_departamentos_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuarios(id) ON DELETE CASCADE;


--
-- Name: usuario_roles usuario_roles_asignado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.usuario_roles
    ADD CONSTRAINT usuario_roles_asignado_por_fkey FOREIGN KEY (asignado_por) REFERENCES public.usuarios(id);


--
-- Name: usuario_roles usuario_roles_rol_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.usuario_roles
    ADD CONSTRAINT usuario_roles_rol_id_fkey FOREIGN KEY (rol_id) REFERENCES public.roles(id) ON DELETE CASCADE;


--
-- Name: usuario_roles usuario_roles_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public.usuario_roles
    ADD CONSTRAINT usuario_roles_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuarios(id) ON DELETE CASCADE;


--
-- Name: boq_control fk_boq_area; Type: FK CONSTRAINT; Schema: sigco; Owner: erp_user
--

ALTER TABLE ONLY sigco.boq_control
    ADD CONSTRAINT fk_boq_area FOREIGN KEY (area_codigo) REFERENCES sigco.cat_areas_frentes(area_codigo);


--
-- Name: boq_control fk_boq_familia; Type: FK CONSTRAINT; Schema: sigco; Owner: erp_user
--

ALTER TABLE ONLY sigco.boq_control
    ADD CONSTRAINT fk_boq_familia FOREIGN KEY (familia_id) REFERENCES sigco.cat_familias(familia_id);


--
-- Name: boq_control fk_boq_unidad; Type: FK CONSTRAINT; Schema: sigco; Owner: erp_user
--

ALTER TABLE ONLY sigco.boq_control
    ADD CONSTRAINT fk_boq_unidad FOREIGN KEY (unidad_id) REFERENCES sigco.cat_unidades(unidad_id);


--
-- Name: boq_control fk_boq_wbs; Type: FK CONSTRAINT; Schema: sigco; Owner: erp_user
--

ALTER TABLE ONLY sigco.boq_control
    ADD CONSTRAINT fk_boq_wbs FOREIGN KEY (wbs_id) REFERENCES sigco.wbs(wbs_id);


--
-- Name: pd_personal_hh fk_pd_hh_area; Type: FK CONSTRAINT; Schema: sigco; Owner: erp_user
--

ALTER TABLE ONLY sigco.pd_personal_hh
    ADD CONSTRAINT fk_pd_hh_area FOREIGN KEY (area_codigo) REFERENCES sigco.cat_areas_frentes(area_codigo);


--
-- Name: pd_personal_hh fk_pd_hh_categoria; Type: FK CONSTRAINT; Schema: sigco; Owner: erp_user
--

ALTER TABLE ONLY sigco.pd_personal_hh
    ADD CONSTRAINT fk_pd_hh_categoria FOREIGN KEY (categoria_id) REFERENCES sigco.cat_categorias_personal(categoria_id);


--
-- Name: pd_personal_hh fk_pd_hh_header; Type: FK CONSTRAINT; Schema: sigco; Owner: erp_user
--

ALTER TABLE ONLY sigco.pd_personal_hh
    ADD CONSTRAINT fk_pd_hh_header FOREIGN KEY (pd_id) REFERENCES sigco.pd_header(pd_id) ON DELETE CASCADE;


--
-- Name: pd_equipos_hm fk_pd_hm_area; Type: FK CONSTRAINT; Schema: sigco; Owner: erp_user
--

ALTER TABLE ONLY sigco.pd_equipos_hm
    ADD CONSTRAINT fk_pd_hm_area FOREIGN KEY (area_codigo) REFERENCES sigco.cat_areas_frentes(area_codigo);


--
-- Name: pd_equipos_hm fk_pd_hm_equipo; Type: FK CONSTRAINT; Schema: sigco; Owner: erp_user
--

ALTER TABLE ONLY sigco.pd_equipos_hm
    ADD CONSTRAINT fk_pd_hm_equipo FOREIGN KEY (equipo_id) REFERENCES sigco.cat_equipos(equipo_id);


--
-- Name: pd_equipos_hm fk_pd_hm_header; Type: FK CONSTRAINT; Schema: sigco; Owner: erp_user
--

ALTER TABLE ONLY sigco.pd_equipos_hm
    ADD CONSTRAINT fk_pd_hm_header FOREIGN KEY (pd_id) REFERENCES sigco.pd_header(pd_id) ON DELETE CASCADE;


--
-- Name: pd_produccion fk_pd_prod_etapa; Type: FK CONSTRAINT; Schema: sigco; Owner: erp_user
--

ALTER TABLE ONLY sigco.pd_produccion
    ADD CONSTRAINT fk_pd_prod_etapa FOREIGN KEY (etapa_id) REFERENCES sigco.cat_etapas(etapa_id);


--
-- Name: pd_produccion_fotos fk_pd_prod_foto_file; Type: FK CONSTRAINT; Schema: sigco; Owner: erp_user
--

ALTER TABLE ONLY sigco.pd_produccion_fotos
    ADD CONSTRAINT fk_pd_prod_foto_file FOREIGN KEY (file_id) REFERENCES public.directus_files(id);


--
-- Name: pd_produccion_fotos fk_pd_prod_foto_prod; Type: FK CONSTRAINT; Schema: sigco; Owner: erp_user
--

ALTER TABLE ONLY sigco.pd_produccion_fotos
    ADD CONSTRAINT fk_pd_prod_foto_prod FOREIGN KEY (produccion_id) REFERENCES sigco.pd_produccion(id_registro) ON DELETE CASCADE;


--
-- Name: pd_produccion_fotos fk_pd_prod_foto_produccion; Type: FK CONSTRAINT; Schema: sigco; Owner: erp_user
--

ALTER TABLE ONLY sigco.pd_produccion_fotos
    ADD CONSTRAINT fk_pd_prod_foto_produccion FOREIGN KEY (produccion_id) REFERENCES sigco.pd_produccion(id_registro) ON DELETE CASCADE;


--
-- Name: pd_produccion fk_pd_prod_header; Type: FK CONSTRAINT; Schema: sigco; Owner: erp_user
--

ALTER TABLE ONLY sigco.pd_produccion
    ADD CONSTRAINT fk_pd_prod_header FOREIGN KEY (pd_id) REFERENCES sigco.pd_header(pd_id) ON DELETE CASCADE;


--
-- Name: pd_produccion fk_pd_prod_item; Type: FK CONSTRAINT; Schema: sigco; Owner: erp_user
--

ALTER TABLE ONLY sigco.pd_produccion
    ADD CONSTRAINT fk_pd_prod_item FOREIGN KEY (control_item_id) REFERENCES sigco.boq_control(control_item_id);


--
-- Name: pd_restricciones fk_pd_res_area; Type: FK CONSTRAINT; Schema: sigco; Owner: erp_user
--

ALTER TABLE ONLY sigco.pd_restricciones
    ADD CONSTRAINT fk_pd_res_area FOREIGN KEY (area_codigo) REFERENCES sigco.cat_areas_frentes(area_codigo);


--
-- Name: pd_restricciones fk_pd_res_header; Type: FK CONSTRAINT; Schema: sigco; Owner: erp_user
--

ALTER TABLE ONLY sigco.pd_restricciones
    ADD CONSTRAINT fk_pd_res_header FOREIGN KEY (pd_id) REFERENCES sigco.pd_header(pd_id) ON DELETE CASCADE;


--
-- Name: pd_restricciones fk_pd_res_restr; Type: FK CONSTRAINT; Schema: sigco; Owner: erp_user
--

ALTER TABLE ONLY sigco.pd_restricciones
    ADD CONSTRAINT fk_pd_res_restr FOREIGN KEY (restriccion_id) REFERENCES sigco.cat_restricciones(restriccion_id);


--
-- Name: boq_control fk_sigco_boq_project; Type: FK CONSTRAINT; Schema: sigco; Owner: erp_user
--

ALTER TABLE ONLY sigco.boq_control
    ADD CONSTRAINT fk_sigco_boq_project FOREIGN KEY (project_id) REFERENCES sigco.projects(project_id) NOT VALID;


--
-- Name: pd_header fk_sigco_pd_project; Type: FK CONSTRAINT; Schema: sigco; Owner: erp_user
--

ALTER TABLE ONLY sigco.pd_header
    ADD CONSTRAINT fk_sigco_pd_project FOREIGN KEY (project_id) REFERENCES sigco.projects(project_id) NOT VALID;


--
-- Name: wbs fk_sigco_wbs_project; Type: FK CONSTRAINT; Schema: sigco; Owner: erp_user
--

ALTER TABLE ONLY sigco.wbs
    ADD CONSTRAINT fk_sigco_wbs_project FOREIGN KEY (project_id) REFERENCES sigco.projects(project_id) NOT VALID;


--
-- Name: wbs fk_wbs_padre; Type: FK CONSTRAINT; Schema: sigco; Owner: erp_user
--

ALTER TABLE ONLY sigco.wbs
    ADD CONSTRAINT fk_wbs_padre FOREIGN KEY (wbs_padre_id) REFERENCES sigco.wbs(wbs_id) ON DELETE SET NULL;


--
-- Name: op_project_map fk_op_project_map_sigco_project; Type: FK CONSTRAINT; Schema: sigco_int; Owner: erp_user
--

ALTER TABLE ONLY sigco_int.op_project_map
    ADD CONSTRAINT fk_op_project_map_sigco_project FOREIGN KEY (sigco_project_id) REFERENCES sigco.projects(project_id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA public TO bi_reader;
GRANT USAGE ON SCHEMA public TO app_writer;


--
-- Name: TABLE departamentos; Type: ACL; Schema: public; Owner: erp_user
--

GRANT SELECT ON TABLE public.departamentos TO bi_reader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.departamentos TO app_writer;


--
-- Name: TABLE directus_activity; Type: ACL; Schema: public; Owner: erp_user
--

GRANT SELECT ON TABLE public.directus_activity TO bi_reader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.directus_activity TO app_writer;


--
-- Name: TABLE directus_collections; Type: ACL; Schema: public; Owner: erp_user
--

GRANT SELECT ON TABLE public.directus_collections TO bi_reader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.directus_collections TO app_writer;


--
-- Name: TABLE directus_dashboards; Type: ACL; Schema: public; Owner: erp_user
--

GRANT SELECT ON TABLE public.directus_dashboards TO bi_reader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.directus_dashboards TO app_writer;


--
-- Name: TABLE directus_extensions; Type: ACL; Schema: public; Owner: erp_user
--

GRANT SELECT ON TABLE public.directus_extensions TO bi_reader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.directus_extensions TO app_writer;


--
-- Name: TABLE directus_fields; Type: ACL; Schema: public; Owner: erp_user
--

GRANT SELECT ON TABLE public.directus_fields TO bi_reader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.directus_fields TO app_writer;


--
-- Name: TABLE directus_files; Type: ACL; Schema: public; Owner: erp_user
--

GRANT SELECT ON TABLE public.directus_files TO bi_reader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.directus_files TO app_writer;


--
-- Name: TABLE directus_flows; Type: ACL; Schema: public; Owner: erp_user
--

GRANT SELECT ON TABLE public.directus_flows TO bi_reader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.directus_flows TO app_writer;


--
-- Name: TABLE directus_folders; Type: ACL; Schema: public; Owner: erp_user
--

GRANT SELECT ON TABLE public.directus_folders TO bi_reader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.directus_folders TO app_writer;


--
-- Name: TABLE directus_migrations; Type: ACL; Schema: public; Owner: erp_user
--

GRANT SELECT ON TABLE public.directus_migrations TO bi_reader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.directus_migrations TO app_writer;


--
-- Name: TABLE directus_notifications; Type: ACL; Schema: public; Owner: erp_user
--

GRANT SELECT ON TABLE public.directus_notifications TO bi_reader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.directus_notifications TO app_writer;


--
-- Name: TABLE directus_operations; Type: ACL; Schema: public; Owner: erp_user
--

GRANT SELECT ON TABLE public.directus_operations TO bi_reader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.directus_operations TO app_writer;


--
-- Name: TABLE directus_panels; Type: ACL; Schema: public; Owner: erp_user
--

GRANT SELECT ON TABLE public.directus_panels TO bi_reader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.directus_panels TO app_writer;


--
-- Name: TABLE directus_permissions; Type: ACL; Schema: public; Owner: erp_user
--

GRANT SELECT ON TABLE public.directus_permissions TO bi_reader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.directus_permissions TO app_writer;


--
-- Name: TABLE directus_presets; Type: ACL; Schema: public; Owner: erp_user
--

GRANT SELECT ON TABLE public.directus_presets TO bi_reader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.directus_presets TO app_writer;


--
-- Name: TABLE directus_relations; Type: ACL; Schema: public; Owner: erp_user
--

GRANT SELECT ON TABLE public.directus_relations TO bi_reader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.directus_relations TO app_writer;


--
-- Name: TABLE directus_revisions; Type: ACL; Schema: public; Owner: erp_user
--

GRANT SELECT ON TABLE public.directus_revisions TO bi_reader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.directus_revisions TO app_writer;


--
-- Name: TABLE directus_roles; Type: ACL; Schema: public; Owner: erp_user
--

GRANT SELECT ON TABLE public.directus_roles TO bi_reader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.directus_roles TO app_writer;


--
-- Name: TABLE directus_sessions; Type: ACL; Schema: public; Owner: erp_user
--

GRANT SELECT ON TABLE public.directus_sessions TO bi_reader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.directus_sessions TO app_writer;


--
-- Name: TABLE directus_settings; Type: ACL; Schema: public; Owner: erp_user
--

GRANT SELECT ON TABLE public.directus_settings TO bi_reader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.directus_settings TO app_writer;


--
-- Name: TABLE directus_shares; Type: ACL; Schema: public; Owner: erp_user
--

GRANT SELECT ON TABLE public.directus_shares TO bi_reader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.directus_shares TO app_writer;


--
-- Name: TABLE directus_translations; Type: ACL; Schema: public; Owner: erp_user
--

GRANT SELECT ON TABLE public.directus_translations TO bi_reader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.directus_translations TO app_writer;


--
-- Name: TABLE directus_users; Type: ACL; Schema: public; Owner: erp_user
--

GRANT SELECT ON TABLE public.directus_users TO bi_reader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.directus_users TO app_writer;


--
-- Name: TABLE directus_versions; Type: ACL; Schema: public; Owner: erp_user
--

GRANT SELECT ON TABLE public.directus_versions TO bi_reader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.directus_versions TO app_writer;


--
-- Name: TABLE directus_webhooks; Type: ACL; Schema: public; Owner: erp_user
--

GRANT SELECT ON TABLE public.directus_webhooks TO bi_reader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.directus_webhooks TO app_writer;


--
-- Name: TABLE organizaciones; Type: ACL; Schema: public; Owner: erp_user
--

GRANT SELECT ON TABLE public.organizaciones TO bi_reader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.organizaciones TO app_writer;


--
-- Name: TABLE proyecto_miembros; Type: ACL; Schema: public; Owner: erp_user
--

GRANT SELECT ON TABLE public.proyecto_miembros TO bi_reader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.proyecto_miembros TO app_writer;


--
-- Name: TABLE proyectos; Type: ACL; Schema: public; Owner: erp_user
--

GRANT SELECT ON TABLE public.proyectos TO bi_reader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.proyectos TO app_writer;


--
-- Name: TABLE roles; Type: ACL; Schema: public; Owner: erp_user
--

GRANT SELECT ON TABLE public.roles TO bi_reader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.roles TO app_writer;


--
-- Name: TABLE tareas; Type: ACL; Schema: public; Owner: erp_user
--

GRANT SELECT ON TABLE public.tareas TO bi_reader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tareas TO app_writer;


--
-- Name: TABLE usuario_departamentos; Type: ACL; Schema: public; Owner: erp_user
--

GRANT SELECT ON TABLE public.usuario_departamentos TO bi_reader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.usuario_departamentos TO app_writer;


--
-- Name: TABLE usuario_roles; Type: ACL; Schema: public; Owner: erp_user
--

GRANT SELECT ON TABLE public.usuario_roles TO bi_reader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.usuario_roles TO app_writer;


--
-- Name: TABLE usuarios; Type: ACL; Schema: public; Owner: erp_user
--

GRANT SELECT ON TABLE public.usuarios TO bi_reader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.usuarios TO app_writer;


--
-- Name: TABLE vw_resumen_tareas_por_estado; Type: ACL; Schema: public; Owner: erp_user
--

GRANT SELECT ON TABLE public.vw_resumen_tareas_por_estado TO bi_reader;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_resumen_tareas_por_estado TO app_writer;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: erp_user
--

ALTER DEFAULT PRIVILEGES FOR ROLE erp_user IN SCHEMA public GRANT SELECT ON TABLES TO bi_reader;
ALTER DEFAULT PRIVILEGES FOR ROLE erp_user IN SCHEMA public GRANT SELECT,INSERT,DELETE,UPDATE ON TABLES TO app_writer;


--
-- PostgreSQL database dump complete
--

\unrestrict cwN11V9mPpXuADfpPf3yBgfh9QwQrwUclgHxVuIy8cgOTn2uH39hc8XPSDQSzwa

