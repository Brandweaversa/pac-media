-- ============================================================
--  PAC MEDIA - DATABASE UPDATE (run this on your EXISTING project)
--
--  Adds the new branding options (square logo, magazine logo
--  border/size settings), repairs table permissions, and makes
--  sure the image storage bucket exists so uploads work.
--
--  How to use: Supabase Dashboard > SQL Editor > New query >
--  paste this ENTIRE file > Run.
--  Safe to run more than once. Deletes nothing.
-- ============================================================

-- ---------- 1. New branding columns ----------
alter table public.app_settings add column if not exists square_logo_url text;
alter table public.app_settings add column if not exists mag_logo_radius int not null default 16;
alter table public.app_settings add column if not exists mag_logo_border_w int not null default 2;
alter table public.app_settings add column if not exists mag_logo_border_color text not null default '#C8102E';

-- ---------- 2. Table permissions (repairs "permission denied") ----------
grant usage on schema public to anon, authenticated, service_role;
grant all on all tables in schema public to anon, authenticated, service_role;
grant all on all sequences in schema public to anon, authenticated, service_role;
grant all on all functions in schema public to anon, authenticated, service_role;
alter default privileges in schema public grant all on tables to anon, authenticated, service_role;
alter default privileges in schema public grant all on sequences to anon, authenticated, service_role;
alter default privileges in schema public grant all on functions to anon, authenticated, service_role;

-- ---------- 3. Image storage bucket (this is where uploads go) ----------
insert into storage.buckets (id, name, public)
values ('media', 'media', true)
on conflict (id) do update set public = true;

drop policy if exists "media_read_all" on storage.objects;
create policy "media_read_all" on storage.objects
  for select using (bucket_id = 'media');

drop policy if exists "media_admin_insert" on storage.objects;
create policy "media_admin_insert" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'media');

drop policy if exists "media_admin_update" on storage.objects;
create policy "media_admin_update" on storage.objects
  for update to authenticated
  using (bucket_id = 'media');

drop policy if exists "media_admin_delete" on storage.objects;
create policy "media_admin_delete" on storage.objects
  for delete to authenticated
  using (bucket_id = 'media');

-- ---------- 4. Make sure the starter settings row exists ----------
insert into public.app_settings (id) values (1)
on conflict (id) do nothing;

-- ---------- 5. Re-apply grants so new tables/columns are covered ----------
grant all on all tables in schema public to anon, authenticated, service_role;
grant all on all sequences in schema public to anon, authenticated, service_role;

-- ============================================================
--  Done! Now re-upload the updated website files and reload
--  your app twice so it picks up the new version.
-- ============================================================
