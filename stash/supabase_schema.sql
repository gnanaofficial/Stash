-- ==============================================================================
-- STASH DATABASE SCHEMA (SUPABASE POSTGRESQL + ROW LEVEL SECURITY)
-- ==============================================================================

-- 1. Reset: Drop existing tables cleanly if any
drop table if exists public.resources cascade;
drop table if exists public.collections cascade;
drop table if exists public.profiles cascade;

-- 2. Profiles table (linked to Supabase auth.users)
create table public.profiles (
  id uuid references auth.users(id) on delete cascade primary key,
  email text,
  username text,
  avatar_url text,
  created_at timestamptz default now()
);

-- Trigger to automatically create a profile when user signs up
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email, username, avatar_url)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'username', split_part(new.email, '@', 1)),
    coalesce(new.raw_user_meta_data->>'avatar_url', '')
  );
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- 3. Collections table (User-isolated)
create table public.collections (
  id text primary key,
  user_id uuid references auth.users(id) on delete cascade default auth.uid(),
  name text not null,
  emoji text default '📁',
  color_index integer default 0,
  description text default '',
  tags text[] default '{}',
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- 4. Resources table (Links, Reels, Docs, Videos, Food Spots)
create table public.resources (
  id text primary key,
  user_id uuid references auth.users(id) on delete cascade default auth.uid(),
  collection_id text references public.collections(id) on delete cascade,
  url text not null,
  title text default '',
  description text default '',
  thumbnail_url text default '',
  type text default 'link',
  source text default 'web',
  notes text default '',
  latitude double precision,
  longitude double precision,
  location_name text,
  is_favorite boolean default false,
  tags text[] default '{}',
  created_at timestamptz default now()
);

-- 5. Enable Row Level Security (RLS) so users only see their own vault items
alter table public.profiles enable row level security;
alter table public.collections enable row level security;
alter table public.resources enable row level security;

-- Profiles Policies
create policy "Users can view their own profile"
  on public.profiles for select
  using (auth.uid() = id);

create policy "Users can update their own profile"
  on public.profiles for update
  using (auth.uid() = id);

-- Collections Policies
create policy "Users can view own collections"
  on public.collections for select
  using (auth.uid() = user_id or auth.uid() is null);

create policy "Users can insert own collections"
  on public.collections for insert
  with check (auth.uid() = user_id or user_id is null);

create policy "Users can update own collections"
  on public.collections for update
  using (auth.uid() = user_id or user_id is null);

create policy "Users can delete own collections"
  on public.collections for delete
  using (auth.uid() = user_id or user_id is null);

-- Resources Policies
create policy "Users can view own resources"
  on public.resources for select
  using (auth.uid() = user_id or auth.uid() is null);

create policy "Users can insert own resources"
  on public.resources for insert
  with check (auth.uid() = user_id or user_id is null);

create policy "Users can update own resources"
  on public.resources for update
  using (auth.uid() = user_id or user_id is null);

create policy "Users can delete own resources"
  on public.resources for delete
  using (auth.uid() = user_id or user_id is null);


-- Milestone 2 & 4 Extensions
alter table public.resources add column if not exists collection_ids text[] default '{}';
alter table public.resources add column if not exists processing_state text default 'organized';

-- 6. Places & Discovery Table
create table if not exists public.places (
  id text primary key,
  user_id uuid references auth.users(id) on delete cascade,
  name text not null,
  category text default 'food',
  city text default '',
  address text default '',
  latitude double precision default 0.0,
  longitude double precision default 0.0,
  price_level text default '$',
  rating double precision default 4.5,
  image_url text default '',
  linked_resource_ids text[] default '{}',
  is_saved boolean default false,
  is_visited boolean default false,
  notes text default '',
  is_curated boolean default false,
  created_at timestamptz default now()
);

alter table public.places enable row level security;

create policy "Users can view curated or own places"
  on public.places for select
  using (is_curated = true or auth.uid() = user_id or auth.uid() is null);

create policy "Users can insert own places"
  on public.places for insert
  with check (auth.uid() = user_id or user_id is null);

create policy "Users can update own places"
  on public.places for update
  using (auth.uid() = user_id or user_id is null);

create policy "Users can delete own places"
  on public.places for delete
  using (auth.uid() = user_id or user_id is null);

-- 7. Performance Indexes for Production Hardening
create index if not exists idx_resources_user_id on public.resources(user_id);
create index if not exists idx_resources_created_at on public.resources(created_at desc);
create index if not exists idx_resources_type on public.resources(type);
create index if not exists idx_collections_user_id on public.collections(user_id);
create index if not exists idx_places_user_id on public.places(user_id);
create index if not exists idx_places_city on public.places(city);
create index if not exists idx_places_is_saved on public.places(is_saved);
