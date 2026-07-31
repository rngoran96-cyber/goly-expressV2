-- ============================================================
-- GOLY EXPRESS — Schéma de base de données (Supabase / PostgreSQL)
-- ============================================================
-- Comment l'utiliser :
-- 1. Crée un projet sur https://supabase.com (gratuit)
-- 2. Va dans "SQL Editor" > "New query"
-- 3. Colle tout ce fichier et clique "Run"
-- ============================================================

-- Extension pour générer des UUID
create extension if not exists "pgcrypto";

-- ---------- ZONES & TARIFS ----------
create table zones_tarifs (
  id uuid primary key default gen_random_uuid(),
  nom_zone text not null,
  tarif_base numeric not null default 500,      -- prix de départ (FCFA)
  tarif_km numeric not null default 150,         -- prix par km additionnel
  actif boolean not null default true,
  created_at timestamptz not null default now()
);

-- ---------- CLIENTS ----------
create table clients (
  id uuid primary key default gen_random_uuid(),
  nom text,
  telephone text unique not null,
  created_at timestamptz not null default now()
);

-- ---------- COURSIERS (livreurs) ----------
create table coursiers (
  id uuid primary key default gen_random_uuid(),
  nom text not null,
  telephone text unique not null,
  vehicule text default 'moto',
  statut text not null default 'hors_ligne'
    check (statut in ('disponible','en_course','hors_ligne')),
  position_lat double precision,
  position_lng double precision,
  position_maj_at timestamptz,
  actif boolean not null default true,
  created_at timestamptz not null default now()
);

-- ---------- COMMANDES ----------
create table commandes (
  id uuid primary key default gen_random_uuid(),
  numero_billet text unique not null,            -- ex: GLY-482913
  client_id uuid references clients(id),
  coursier_id uuid references coursiers(id),
  type text not null,                             -- pli / colis / repas / demenagement
  depart text not null,
  arrivee text not null,
  telephone text not null,
  statut text not null default 'en_attente'
    check (statut in ('en_attente','coursier_affecte','en_route','livre','annule')),
  prix numeric,
  statut_paiement text not null default 'non_paye'
    check (statut_paiement in ('non_paye','paye','rembourse')),
  moyen_paiement text,                            -- orange_money / mtn_money / wave / especes
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ---------- HISTORIQUE DES STATUTS (timeline du suivi) ----------
create table historique_statuts (
  id uuid primary key default gen_random_uuid(),
  commande_id uuid references commandes(id) on delete cascade,
  statut text not null,
  note text,
  created_at timestamptz not null default now()
);

-- Met à jour updated_at automatiquement + log dans l'historique à chaque changement de statut
create or replace function fn_commande_statut_change()
returns trigger as $$
begin
  new.updated_at = now();
  if (tg_op = 'UPDATE' and old.statut is distinct from new.statut) or tg_op = 'INSERT' then
    insert into historique_statuts (commande_id, statut) values (new.id, new.statut);
  end if;
  return new;
end;
$$ language plpgsql;

create trigger trg_commande_statut
before insert or update on commandes
for each row execute function fn_commande_statut_change();

-- ============================================================
-- SÉCURITÉ (Row Level Security)
-- ============================================================
alter table commandes enable row level security;
alter table historique_statuts enable row level security;
alter table coursiers enable row level security;
alter table clients enable row level security;
alter table zones_tarifs enable row level security;

-- Le public (site web) peut CRÉER une commande (formulaire de réservation)
create policy "public_insert_commande" on commandes
  for insert to anon with check (true);

-- Le public peut CONSULTER une commande uniquement s'il connaît le numéro de billet exact
-- (le numéro de billet sert de "clé" de suivi, comme un numéro de colis La Poste)
create policy "public_select_commande_by_billet" on commandes
  for select to anon using (true);
  -- Note MVP : select ouvert pour simplifier le suivi en temps réel sans compte client.
  -- Le filtrage se fait côté application (.eq('numero_billet', ...)).
  -- Passer à une restriction stricte quand l'authentification client sera activée.

create policy "public_select_historique" on historique_statuts
  for select to anon using (true);

create policy "public_insert_client" on clients
  for insert to anon with check (true);

create policy "public_select_zones" on zones_tarifs
  for select to anon using (true);

-- Coursiers : lecture publique limitée à la position pour la course en cours
-- (à restreindre davantage une fois l'app livreur + admin en place avec rôles dédiés)
create policy "public_select_coursier_position" on coursiers
  for select to anon using (true);

-- ============================================================
-- DONNÉES DE DÉPART — zones de Bouaké (à ajuster librement)
-- ============================================================
insert into zones_tarifs (nom_zone, tarif_base, tarif_km) values
  ('Commerce', 500, 150),
  ('Zone', 500, 150),
  ('Nimbo', 600, 150),
  ('Air France', 600, 150),
  ('Kennedy', 700, 150),
  ('Broukro', 700, 150);

-- ============================================================
-- Activer le temps réel sur la table commandes (pour le suivi live)
-- ============================================================
alter publication supabase_realtime add table commandes;
alter publication supabase_realtime add table coursiers;
