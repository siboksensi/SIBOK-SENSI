create extension if not exists pgcrypto;
create type public.app_role as enum ('super_admin','admin','moderator','customer');
create type public.key_status as enum ('active','revoked','expired');
create table public.user_roles(user_id uuid primary key references auth.users(id) on delete cascade, role public.app_role not null default 'customer', created_at timestamptz not null default now());
create table public.access_keys(id uuid primary key default gen_random_uuid(), key_hash text not null unique, label text, status public.key_status not null default 'active', duration_code text not null check(duration_code in ('1d','3d','7d','15d','30d','3m','1y','lifetime')), expires_at timestamptz, max_devices integer not null default 1 check(max_devices between 1 and 20), created_by uuid references auth.users(id), created_at timestamptz not null default now(), revoked_at timestamptz, notes text);
create table public.key_activations(id uuid primary key default gen_random_uuid(), access_key_id uuid not null references public.access_keys(id) on delete cascade, user_id uuid references auth.users(id) on delete set null, device_fingerprint_hash text, activated_at timestamptz not null default now(), last_seen_at timestamptz not null default now(), unique(access_key_id,device_fingerprint_hash));
create table public.profiles(id uuid primary key default gen_random_uuid(), slug text not null unique, title text not null, device_group text not null default 'Android — General', description text not null default '', settings jsonb not null default '{}'::jsonb, file_path text, is_published boolean not null default false, required_plan text not null default 'standard', version integer not null default 1, updated_by uuid references auth.users(id), updated_at timestamptz not null default now());
create table public.feature_catalog(id text primary key, name text not null, category text not null, description text not null default '', is_enabled boolean not null default false, rollout jsonb not null default '{}'::jsonb, updated_at timestamptz not null default now());
create table public.site_settings(key text primary key, value jsonb not null default '{}'::jsonb, updated_by uuid references auth.users(id), updated_at timestamptz not null default now());
create table public.audit_logs(id bigint generated always as identity primary key, actor_id uuid references auth.users(id) on delete set null, action text not null, target_type text not null, target_id text, details jsonb not null default '{}'::jsonb, created_at timestamptz not null default now());
create or replace function public.has_admin_role() returns boolean language sql stable security definer set search_path=public as $$ select exists(select 1 from public.user_roles where user_id=auth.uid() and role in ('super_admin','admin','moderator')); $$;
create or replace function public.has_super_admin_role() returns boolean language sql stable security definer set search_path=public as $$ select exists(select 1 from public.user_roles where user_id=auth.uid() and role='super_admin'); $$;
alter table public.user_roles enable row level security; alter table public.access_keys enable row level security; alter table public.key_activations enable row level security; alter table public.profiles enable row level security; alter table public.feature_catalog enable row level security; alter table public.site_settings enable row level security; alter table public.audit_logs enable row level security;
create policy "read own role or admin" on public.user_roles for select using(user_id=auth.uid() or public.has_admin_role());
create policy "super admin manages roles" on public.user_roles for all using(public.has_super_admin_role()) with check(public.has_super_admin_role());
create policy "admins read access keys" on public.access_keys for select using(public.has_admin_role());
create policy "admins read activations" on public.key_activations for select using(public.has_admin_role());
create policy "public reads published profiles" on public.profiles for select using(is_published=true);
create policy "admins manage profiles" on public.profiles for all using(public.has_admin_role()) with check(public.has_admin_role());
create policy "public reads enabled feature catalog" on public.feature_catalog for select using(is_enabled=true);
create policy "admins manage feature catalog" on public.feature_catalog for all using(public.has_admin_role()) with check(public.has_admin_role());
create policy "public reads public settings" on public.site_settings for select using(key in ('maintenance_mode','maintenance_message','announcement'));
create policy "admins manage site settings" on public.site_settings for all using(public.has_admin_role()) with check(public.has_admin_role());
create policy "admins read audit logs" on public.audit_logs for select using(public.has_admin_role());
insert into public.site_settings(key,value) values('maintenance_mode','false'::jsonb),('maintenance_message','"We are updating SIBOK SENSI PRO. Please check back soon."'::jsonb),('announcement','""'::jsonb) on conflict(key) do nothing;
-- No browser-side write policies for keys, activations, or audit logs. Use authenticated Edge Functions.
-- Store downloads in a private Storage bucket and issue short-lived signed URLs only after server-side key checks.
-- Never expose the service_role secret in browser code.
