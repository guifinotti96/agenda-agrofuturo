-- Agenda Agrofuturo: tabelas e regras de acesso.
-- Rode tudo de uma vez no Supabase: SQL Editor > New query > cole > Run.

-- Conta mestre: quem entrar com este e-mail vê e altera tudo.
create or replace function public.is_master() returns boolean
language sql stable set search_path = '' as $$
  select coalesce(lower(auth.jwt() ->> 'email') = 'guifinotti96@gmail.com', false)
$$;

-- Clientes, compromissos e perfis: cada linha pertence a um usuário (owner_id).
create table if not exists public.leads (
  id text primary key,
  owner_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  data jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.eventos (
  id text primary key,
  owner_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  data jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.usuarios (
  id text primary key,
  owner_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  data jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists leads_owner_idx on public.leads (owner_id);
create index if not exists eventos_owner_idx on public.eventos (owner_id);
create index if not exists usuarios_owner_idx on public.usuarios (owner_id);

-- Funis: da empresa toda. Todos leem, só a conta mestre altera.
create table if not exists public.funis (
  id text primary key,
  owner_id uuid default auth.uid(),
  data jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.leads    enable row level security;
alter table public.eventos  enable row level security;
alter table public.usuarios enable row level security;
alter table public.funis    enable row level security;

-- Cada usuário só vê e altera o que é dele; a conta mestre vê e altera tudo.
do $$
declare t text;
begin
  foreach t in array array['leads','eventos','usuarios'] loop
    execute format('drop policy if exists "%1$s_select" on public.%1$s', t);
    execute format('drop policy if exists "%1$s_insert" on public.%1$s', t);
    execute format('drop policy if exists "%1$s_update" on public.%1$s', t);
    execute format('drop policy if exists "%1$s_delete" on public.%1$s', t);
    execute format('create policy "%1$s_select" on public.%1$s for select to authenticated using (owner_id = (select auth.uid()) or (select public.is_master()))', t);
    execute format('create policy "%1$s_insert" on public.%1$s for insert to authenticated with check (owner_id = (select auth.uid()) or (select public.is_master()))', t);
    execute format('create policy "%1$s_update" on public.%1$s for update to authenticated using (owner_id = (select auth.uid()) or (select public.is_master())) with check (owner_id = (select auth.uid()) or (select public.is_master()))', t);
    execute format('create policy "%1$s_delete" on public.%1$s for delete to authenticated using (owner_id = (select auth.uid()) or (select public.is_master()))', t);
  end loop;
end $$;

drop policy if exists "funis_select" on public.funis;
drop policy if exists "funis_write" on public.funis;
drop policy if exists "funis_insert" on public.funis;
drop policy if exists "funis_update" on public.funis;
drop policy if exists "funis_delete" on public.funis;
create policy "funis_select" on public.funis for select to authenticated using (true);
create policy "funis_insert" on public.funis for insert to authenticated with check ((select public.is_master()));
create policy "funis_update" on public.funis for update to authenticated using ((select public.is_master())) with check ((select public.is_master()));
create policy "funis_delete" on public.funis for delete to authenticated using ((select public.is_master()));

-- Atualização em tempo real entre aparelhos.
do $$ begin
  alter publication supabase_realtime add table public.leads, public.eventos, public.usuarios, public.funis;
exception when duplicate_object then null; end $$;

-- Funil padrão de telemarketing.
insert into public.funis (id, owner_id, data) values ('comercial', null, '{
  "nome":"Funil comercial","ordem":1,"etapas":[
    {"id":"novo","nome":"Novo lead","tipo":"aberto"},
    {"id":"contato","nome":"Primeiro contato","tipo":"aberto"},
    {"id":"proposta","nome":"Proposta enviada","tipo":"aberto"},
    {"id":"negociacao","nome":"Negociação","tipo":"aberto"},
    {"id":"ganho","nome":"Venda fechada","tipo":"ganho"},
    {"id":"perdido","nome":"Perdido","tipo":"perdido"}]}'::jsonb)
on conflict (id) do nothing;
