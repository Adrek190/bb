-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.add_child_requests (
  request_id uuid NOT NULL DEFAULT gen_random_uuid(),
  parent_id uuid NOT NULL,
  child_name character varying NOT NULL,
  child_location text NOT NULL,
  profile_image_path character varying,
  gender USER-DEFINED NOT NULL,
  education_level_id uuid NOT NULL,
  requested_school_id uuid NOT NULL,
  requested_district_id uuid NOT NULL,
  requested_city_id uuid NOT NULL,
  requested_entry_time time without time zone NOT NULL,
  requested_exit_time time without time zone NOT NULL,
  requested_study_days ARRAY NOT NULL,
  requested_transport_plan_id uuid NOT NULL,
  status USER-DEFINED DEFAULT 'pending'::request_status_enum,
  submitted_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  processed_at timestamp without time zone,
  processed_by uuid,
  rejection_reason text,
  admin_notes text,
  created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  is_active boolean DEFAULT true,
  CONSTRAINT add_child_requests_pkey PRIMARY KEY (request_id),
  CONSTRAINT add_child_requests_new_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.parents(parent_id),
  CONSTRAINT add_child_requests_new_requested_district_id_fkey FOREIGN KEY (requested_district_id) REFERENCES public.districts(district_id),
  CONSTRAINT add_child_requests_new_requested_city_id_fkey FOREIGN KEY (requested_city_id) REFERENCES public.cities(city_id),
  CONSTRAINT add_child_requests_new_requested_transport_plan_id_fkey FOREIGN KEY (requested_transport_plan_id) REFERENCES public.transport_plans(plan_id)
);
CREATE TABLE public.children (
  child_id uuid NOT NULL DEFAULT gen_random_uuid(),
  child_name character varying NOT NULL,
  child_location text NOT NULL,
  profile_image_path character varying,
  gender USER-DEFINED NOT NULL,
  education_level character varying NOT NULL,
  parent_id uuid NOT NULL,
  school_id uuid NOT NULL,
  district_id uuid NOT NULL,
  entry_time time without time zone NOT NULL,
  exit_time time without time zone NOT NULL,
  study_days jsonb NOT NULL,
  trip_types jsonb NOT NULL,
  created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  is_active boolean DEFAULT true,
  education_level_id uuid,
  profile_image_url text,
  current_location text,
  CONSTRAINT children_pkey PRIMARY KEY (child_id),
  CONSTRAINT fk_children_parent FOREIGN KEY (parent_id) REFERENCES public.parents(parent_id),
  CONSTRAINT fk_children_district FOREIGN KEY (district_id) REFERENCES public.districts(district_id)
);
CREATE TABLE public.cities (
  city_id uuid NOT NULL DEFAULT gen_random_uuid(),
  city_name character varying NOT NULL,
  created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  is_active boolean DEFAULT true,
  CONSTRAINT cities_pkey PRIMARY KEY (city_id)
);
CREATE TABLE public.districts (
  district_id uuid NOT NULL DEFAULT gen_random_uuid(),
  district_name character varying NOT NULL,
  city_id uuid NOT NULL,
  created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  is_active boolean DEFAULT true,
  CONSTRAINT districts_pkey PRIMARY KEY (district_id),
  CONSTRAINT fk_districts_city FOREIGN KEY (city_id) REFERENCES public.cities(city_id)
);
CREATE TABLE public.education_levels (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name character varying NOT NULL UNIQUE,
  name_en character varying,
  description text,
  sort_order integer NOT NULL,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT education_levels_pkey PRIMARY KEY (id)
);
CREATE TABLE public.invoices (
  invoice_id uuid NOT NULL DEFAULT gen_random_uuid(),
  parent_id uuid,
  amount numeric NOT NULL,
  status character varying DEFAULT 'pending'::character varying,
  description text,
  due_date date,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  CONSTRAINT invoices_pkey PRIMARY KEY (invoice_id),
  CONSTRAINT invoices_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.parents(parent_id)
);
CREATE TABLE public.notifications (
  notification_id uuid NOT NULL DEFAULT gen_random_uuid(),
  parent_id uuid,
  title character varying NOT NULL,
  message text NOT NULL,
  type character varying DEFAULT 'info'::character varying,
  is_read boolean DEFAULT false,
  related_request_id uuid,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  CONSTRAINT notifications_pkey PRIMARY KEY (notification_id),
  CONSTRAINT notifications_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.parents(parent_id)
);
CREATE TABLE public.parents (
  parent_id uuid NOT NULL DEFAULT gen_random_uuid(),
  parent_name character varying NOT NULL,
  phone character varying NOT NULL UNIQUE,
  email character varying,
  password_hash character varying NOT NULL,
  is_verified boolean DEFAULT false,
  verification_token character varying,
  created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  last_login timestamp without time zone,
  is_active boolean DEFAULT true,
  auth_id uuid,
  profile_image_url text,
  CONSTRAINT parents_pkey PRIMARY KEY (parent_id),
  CONSTRAINT parents_auth_id_fkey FOREIGN KEY (auth_id) REFERENCES auth.users(id)
);
CREATE TABLE public.schools (
  school_id uuid NOT NULL DEFAULT gen_random_uuid(),
  school_name character varying NOT NULL,
  school_type character varying NOT NULL DEFAULT 'government'::character varying,
  education_level_id uuid NOT NULL,
  district_id uuid NOT NULL,
  full_address text,
  phone character varying,
  email character varying,
  operating_hours_start time without time zone DEFAULT '07:00:00'::time without time zone,
  operating_hours_end time without time zone DEFAULT '14:00:00'::time without time zone,
  working_days ARRAY DEFAULT ARRAY['sunday'::text, 'monday'::text, 'tuesday'::text, 'wednesday'::text, 'thursday'::text],
  capacity integer DEFAULT 500,
  current_students integer DEFAULT 0,
  is_transport_available boolean DEFAULT true,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT schools_pkey PRIMARY KEY (school_id),
  CONSTRAINT schools_education_level_id_fkey FOREIGN KEY (education_level_id) REFERENCES public.education_levels(id),
  CONSTRAINT schools_district_id_fkey FOREIGN KEY (district_id) REFERENCES public.districts(district_id)
);
CREATE TABLE public.study_days (
  day_id uuid NOT NULL DEFAULT gen_random_uuid(),
  day_name_arabic character varying NOT NULL UNIQUE,
  day_name_english character varying NOT NULL UNIQUE,
  day_order integer NOT NULL UNIQUE CHECK (day_order >= 1 AND day_order <= 7),
  is_weekend boolean DEFAULT false,
  is_active boolean DEFAULT true,
  created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT study_days_pkey PRIMARY KEY (day_id)
);
CREATE TABLE public.transport_plans (
  plan_id uuid NOT NULL DEFAULT gen_random_uuid(),
  plan_name_arabic character varying NOT NULL,
  plan_name_english character varying NOT NULL,
  plan_code character varying NOT NULL UNIQUE,
  description_arabic text,
  description_english text,
  trip_types jsonb NOT NULL,
  monthly_price numeric NOT NULL CHECK (monthly_price >= 0::numeric),
  setup_fee numeric DEFAULT 0 CHECK (setup_fee >= 0::numeric),
  features jsonb,
  max_distance_km integer DEFAULT 50,
  is_active boolean DEFAULT true,
  sort_order integer DEFAULT 0,
  created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT transport_plans_pkey PRIMARY KEY (plan_id)
);