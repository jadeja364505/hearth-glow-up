CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS trigger LANGUAGE plpgsql SET search_path = public AS $$
BEGIN NEW.updated_at = now(); RETURN NEW; END; $$;

CREATE TABLE public.profiles (
  id uuid PRIMARY KEY,
  display_name text,
  company_name text,
  theme text NOT NULL DEFAULT 'dark' CHECK (theme IN ('dark','light')),
  plan text NOT NULL DEFAULT 'starter' CHECK (plan IN ('starter','pro','scale')),
  monthly_limit integer NOT NULL DEFAULT 100 CHECK (monthly_limit >= 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.profiles TO authenticated;
GRANT ALL ON public.profiles TO service_role;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "profiles_read_own" ON public.profiles FOR SELECT TO authenticated USING (auth.uid() = id);
CREATE POLICY "profiles_insert_own" ON public.profiles FOR INSERT TO authenticated WITH CHECK (auth.uid() = id);
CREATE POLICY "profiles_update_own" ON public.profiles FOR UPDATE TO authenticated USING (auth.uid() = id) WITH CHECK (auth.uid() = id);
CREATE POLICY "profiles_delete_own" ON public.profiles FOR DELETE TO authenticated USING (auth.uid() = id);
CREATE TRIGGER profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  INSERT INTO public.profiles (id, display_name, company_name)
  VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1)), NEW.raw_user_meta_data->>'company_name')
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END; $$;
CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

CREATE TABLE public.certificate_templates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  name text NOT NULL,
  description text,
  category text NOT NULL DEFAULT 'custom',
  orientation text NOT NULL DEFAULT 'landscape' CHECK (orientation IN ('landscape','portrait')),
  status text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft','active','archived')),
  design jsonb NOT NULL DEFAULT '{}'::jsonb,
  background_path text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.certificate_templates TO authenticated;
GRANT ALL ON public.certificate_templates TO service_role;
ALTER TABLE public.certificate_templates ENABLE ROW LEVEL SECURITY;
CREATE POLICY "templates_read_own" ON public.certificate_templates FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY "templates_insert_own" ON public.certificate_templates FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY "templates_update_own" ON public.certificate_templates FOR UPDATE TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "templates_delete_own" ON public.certificate_templates FOR DELETE TO authenticated USING (auth.uid() = user_id);
CREATE TRIGGER templates_updated_at BEFORE UPDATE ON public.certificate_templates FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE INDEX certificate_templates_user_id_idx ON public.certificate_templates(user_id);

CREATE TABLE public.template_fields (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  template_id uuid NOT NULL REFERENCES public.certificate_templates(id) ON DELETE CASCADE,
  user_id uuid NOT NULL,
  field_key text NOT NULL,
  label text NOT NULL,
  x numeric NOT NULL DEFAULT 50 CHECK (x BETWEEN 0 AND 100),
  y numeric NOT NULL DEFAULT 50 CHECK (y BETWEEN 0 AND 100),
  font_size integer NOT NULL DEFAULT 24 CHECK (font_size BETWEEN 8 AND 144),
  alignment text NOT NULL DEFAULT 'center' CHECK (alignment IN ('left','center','right')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.template_fields TO authenticated;
GRANT ALL ON public.template_fields TO service_role;
ALTER TABLE public.template_fields ENABLE ROW LEVEL SECURITY;
CREATE POLICY "fields_read_own" ON public.template_fields FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY "fields_insert_own" ON public.template_fields FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id AND EXISTS (SELECT 1 FROM public.certificate_templates t WHERE t.id = template_id AND t.user_id = auth.uid()));
CREATE POLICY "fields_update_own" ON public.template_fields FOR UPDATE TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "fields_delete_own" ON public.template_fields FOR DELETE TO authenticated USING (auth.uid() = user_id);
CREATE TRIGGER fields_updated_at BEFORE UPDATE ON public.template_fields FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE INDEX template_fields_template_id_idx ON public.template_fields(template_id);

CREATE TABLE public.generation_jobs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  template_id uuid REFERENCES public.certificate_templates(id) ON DELETE SET NULL,
  name text NOT NULL,
  source_file_name text,
  source_path text,
  output_path text,
  status text NOT NULL DEFAULT 'queued' CHECK (status IN ('queued','validating','processing','completed','failed')),
  total_count integer NOT NULL DEFAULT 0 CHECK (total_count >= 0),
  success_count integer NOT NULL DEFAULT 0 CHECK (success_count >= 0),
  error_count integer NOT NULL DEFAULT 0 CHECK (error_count >= 0),
  validation_errors jsonb NOT NULL DEFAULT '[]'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.generation_jobs TO authenticated;
GRANT ALL ON public.generation_jobs TO service_role;
ALTER TABLE public.generation_jobs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "jobs_read_own" ON public.generation_jobs FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY "jobs_insert_own" ON public.generation_jobs FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY "jobs_update_own" ON public.generation_jobs FOR UPDATE TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "jobs_delete_own" ON public.generation_jobs FOR DELETE TO authenticated USING (auth.uid() = user_id);
CREATE TRIGGER jobs_updated_at BEFORE UPDATE ON public.generation_jobs FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE INDEX generation_jobs_user_id_created_idx ON public.generation_jobs(user_id, created_at DESC);

CREATE TABLE public.billing_records (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  description text NOT NULL,
  amount_minor integer NOT NULL DEFAULT 0,
  currency text NOT NULL DEFAULT 'INR',
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','paid','failed','refunded')),
  issued_at timestamptz NOT NULL DEFAULT now(),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT ON public.billing_records TO authenticated;
GRANT ALL ON public.billing_records TO service_role;
ALTER TABLE public.billing_records ENABLE ROW LEVEL SECURITY;
CREATE POLICY "billing_read_own" ON public.billing_records FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE TRIGGER billing_updated_at BEFORE UPDATE ON public.billing_records FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE INDEX billing_records_user_id_idx ON public.billing_records(user_id);

GRANT EXECUTE ON FUNCTION public.set_updated_at() TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.handle_new_user() TO service_role;