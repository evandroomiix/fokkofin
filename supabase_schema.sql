-- FOKKO FIN • Estrutura Oficial do Banco de Dados (Supabase PostgreSQL)
-- Cole este script no SQL Editor do seu painel Supabase e clique em "Run"

-- 1. Extensão para IDs seguros
create extension if not exists "uuid-ossp";

-- 2. Tabela de Perfis de Usuário
create table if not exists public.profiles (
  id uuid references auth.users on delete cascade primary key,
  email text,
  full_name text,
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- 3. Tabela de Transações (Receitas e Despesas do FOKKO FIN)
create table if not exists public.transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users on delete cascade not null,
  description text not null,
  amount numeric not null,
  type text not null check (type in ('income', 'expense')),
  category text,
  account text,
  date date not null default current_date,
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- 4. Tabela de Contas e Cartões
create table if not exists public.accounts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users on delete cascade not null,
  name text not null,
  balance numeric default 0,
  type text default 'corrente',
  color text default 'emerald',
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- 5. Tabela de Caixinhas de Impulso / Metas
create table if not exists public.savings_boxes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users on delete cascade not null,
  name text not null,
  balance numeric default 0,
  goal numeric default 0,
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- 6. Ativar Segurança de Dados por Usuário (Row Level Security - RLS)
-- Garante que um usuário NUNCA consiga ver ou alterar os dados de outro!
alter table public.profiles enable row level security;
alter table public.transactions enable row level security;
alter table public.accounts enable row level security;
alter table public.savings_boxes enable row level security;

-- Políticas de Privacidade RLS
create policy "Users can manage their own profile" on public.profiles
  for all using (auth.uid() = id);

create policy "Users can manage their own transactions" on public.transactions
  for all using (auth.uid() = user_id);

create policy "Users can manage their own accounts" on public.accounts
  for all using (auth.uid() = user_id);

create policy "Users can manage their own savings boxes" on public.savings_boxes
  for all using (auth.uid() = user_id);
