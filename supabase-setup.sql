-- ============================================================
--  PAC MEDIA - SUPABASE DATABASE SETUP
--  How to use: Supabase Dashboard > SQL Editor > New query >
--  paste this ENTIRE file > Run.
--  Safe to run more than once (it will not duplicate anything).
-- ============================================================

-- ---------- 1. TABLES ----------
create table if not exists public.app_settings (
  id int primary key default 1 check (id = 1),
  admin_user_id uuid,
  admin_created boolean not null default false,
  app_name text not null default 'PAC Media',
  brand_red text not null default '#C8102E',
  splash_logo_w int not null default 327,
  splash_logo_h int not null default 239,
  hub_logo_w int not null default 260,
  logo_url text,
  footer_text text not null default 'A Digital Publishing Platform by Pigeon Advertising & Communications.',
  updated_at timestamptz not null default now()
);

create table if not exists public.magazines (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  logo_url text,
  published boolean not null default true,
  sort_order int not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.issues (
  id uuid primary key default gen_random_uuid(),
  magazine_id uuid not null references public.magazines(id) on delete cascade,
  title text not null,
  thumbnail_url text,
  flipbook_url text not null default '',
  published boolean not null default true,
  sort_order int not null default 0,
  created_at timestamptz not null default now()
);

-- ---------- 2. STARTER SETTINGS ROW ----------
insert into public.app_settings (id) values (1)
on conflict (id) do nothing;

-- ---------- 3. ADMIN CHECK HELPER ----------
create or replace function public.is_pac_admin()
returns boolean
language sql stable security definer
set search_path = public
as $$
  select exists (
    select 1 from public.app_settings
    where id = 1 and admin_user_id = auth.uid()
  );
$$;

-- ---------- 4. ROW LEVEL SECURITY ----------
alter table public.app_settings enable row level security;
alter table public.magazines  enable row level security;
alter table public.issues     enable row level security;

-- settings: readable by everyone, writable only by the admin
drop policy if exists "settings_read_all" on public.app_settings;
create policy "settings_read_all" on public.app_settings
  for select using (true);

drop policy if exists "settings_admin_write" on public.app_settings;
create policy "settings_admin_write" on public.app_settings
  for update to authenticated
  using (admin_user_id is null or admin_user_id = auth.uid())
  with check (admin_user_id is null or admin_user_id = auth.uid());

-- magazines: published ones are public; the admin manages everything
drop policy if exists "magazines_read" on public.magazines;
create policy "magazines_read" on public.magazines
  for select using (published = true or public.is_pac_admin());

drop policy if exists "magazines_insert" on public.magazines;
create policy "magazines_insert" on public.magazines
  for insert to authenticated with check (public.is_pac_admin());

drop policy if exists "magazines_update" on public.magazines;
create policy "magazines_update" on public.magazines
  for update to authenticated using (public.is_pac_admin());

drop policy if exists "magazines_delete" on public.magazines;
create policy "magazines_delete" on public.magazines
  for delete to authenticated using (public.is_pac_admin());

-- issues: same rules as magazines
drop policy if exists "issues_read" on public.issues;
create policy "issues_read" on public.issues
  for select using (published = true or public.is_pac_admin());

drop policy if exists "issues_insert" on public.issues;
create policy "issues_insert" on public.issues
  for insert to authenticated with check (public.is_pac_admin());

drop policy if exists "issues_update" on public.issues;
create policy "issues_update" on public.issues
  for update to authenticated using (public.is_pac_admin());

drop policy if exists "issues_delete" on public.issues;
create policy "issues_delete" on public.issues
  for delete to authenticated using (public.is_pac_admin());

-- ---------- 5. STORAGE BUCKET (magazine images) ----------
insert into storage.buckets (id, name, public)
values ('media', 'media', true)
on conflict (id) do update set public = true;

drop policy if exists "media_read_all" on storage.objects;
create policy "media_read_all" on storage.objects
  for select using (bucket_id = 'media');

drop policy if exists "media_admin_insert" on storage.objects;
create policy "media_admin_insert" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'media' and public.is_pac_admin());

drop policy if exists "media_admin_update" on storage.objects;
create policy "media_admin_update" on storage.objects
  for update to authenticated
  using (bucket_id = 'media' and public.is_pac_admin());

drop policy if exists "media_admin_delete" on storage.objects;
create policy "media_admin_delete" on storage.objects
  for delete to authenticated
  using (bucket_id = 'media' and public.is_pac_admin());

-- ============================================================
--  Done! Next: Setup Guide Step 5 (turn off email confirmation)
--  and Steps 6-7 (copy your Project URL + anon key into config.js)
-- ============================================================
