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

-- ---------- 2. Admin check helper (needed by the policies below) ----------
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

-- ---------- 3. Table permissions (repairs "permission denied") ----------
grant usage on schema public to anon, authenticated, service_role;
grant all on all tables in schema public to anon, authenticated, service_role;
grant all on all sequences in schema public to anon, authenticated, service_role;
grant all on all functions in schema public to anon, authenticated, service_role;
alter default privileges in schema public grant all on tables to anon, authenticated, service_role;
alter default privileges in schema public grant all on sequences to anon, authenticated, service_role;
alter default privileges in schema public grant all on functions to anon, authenticated, service_role;

-- ---------- 4. Security: only the administrator can change content ----------
-- Replaces older policies that allowed ANY signed-in account to write.
-- Reads stay public; writes now require the administrator account.

drop policy if exists "settings_read" on public.app_settings;
drop policy if exists "settings_read_all" on public.app_settings;
create policy "settings_read_all" on public.app_settings
  for select using (true);

drop policy if exists "settings_admin_write" on public.app_settings;
drop policy if exists "settings_admin_update" on public.app_settings;
drop policy if exists "settings_admin_insert" on public.app_settings;
drop policy if exists "settings_admin_delete" on public.app_settings;
create policy "settings_admin_write" on public.app_settings
  for update to authenticated
  using (admin_user_id is null or admin_user_id = auth.uid())
  with check (admin_user_id is null or admin_user_id = auth.uid());

drop policy if exists "magazines_read" on public.magazines;
create policy "magazines_read" on public.magazines
  for select using (published = true or public.is_pac_admin());

drop policy if exists "magazines_insert" on public.magazines;
drop policy if exists "magazines_admin_insert" on public.magazines;
create policy "magazines_insert" on public.magazines
  for insert to authenticated with check (public.is_pac_admin());

drop policy if exists "magazines_update" on public.magazines;
drop policy if exists "magazines_admin_update" on public.magazines;
create policy "magazines_update" on public.magazines
  for update to authenticated using (public.is_pac_admin());

drop policy if exists "magazines_delete" on public.magazines;
drop policy if exists "magazines_admin_delete" on public.magazines;
create policy "magazines_delete" on public.magazines
  for delete to authenticated using (public.is_pac_admin());

drop policy if exists "issues_read" on public.issues;
create policy "issues_read" on public.issues
  for select using (published = true or public.is_pac_admin());

drop policy if exists "issues_insert" on public.issues;
drop policy if exists "issues_admin_insert" on public.issues;
create policy "issues_insert" on public.issues
  for insert to authenticated with check (public.is_pac_admin());

drop policy if exists "issues_update" on public.issues;
drop policy if exists "issues_admin_update" on public.issues;
create policy "issues_update" on public.issues
  for update to authenticated using (public.is_pac_admin());

drop policy if exists "issues_delete" on public.issues;
drop policy if exists "issues_admin_delete" on public.issues;
create policy "issues_delete" on public.issues
  for delete to authenticated using (public.is_pac_admin());

-- ---------- 5. Image storage bucket (this is where uploads go) ----------
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

-- ---------- 6. Make sure the starter settings row exists ----------
insert into public.app_settings (id) values (1)
on conflict (id) do nothing;

-- ---------- 7. Re-apply grants so new tables/columns are covered ----------
grant all on all tables in schema public to anon, authenticated, service_role;
grant all on all sequences in schema public to anon, authenticated, service_role;

-- ============================================================
--  Done! Now re-upload the updated website files and reload
--  your app twice so it picks up the new version.
-- ============================================================
