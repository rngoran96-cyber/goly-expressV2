-- ============================================================
-- GOLY EXPRESS — Correctif définitif : déclencheur historique_statuts
-- ============================================================
-- À exécuter une seule fois dans Supabase > SQL Editor, sur ton projet
-- ACTUEL (celui déjà en service) — inutile si tu repars sur un projet
-- tout neuf avec supabase-schema-COMPLET.sql, le correctif y est déjà inclus.
--
-- Cause du bug : le déclencheur original tentait d'enregistrer l'historique
-- AVANT que la commande soit réellement écrite dans la base (trigger BEFORE),
-- ce qui violait la contrainte de clé étrangère à chaque nouvelle commande.
-- ============================================================

drop trigger if exists trg_commande_statut on commandes;
drop function if exists fn_commande_statut_change();

create or replace function fn_commande_set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger trg_commande_updated_at
before insert or update on commandes
for each row execute function fn_commande_set_updated_at();

create or replace function fn_commande_log_historique()
returns trigger as $$
begin
  if (tg_op = 'UPDATE' and old.statut is distinct from new.statut) or tg_op = 'INSERT' then
    insert into historique_statuts (commande_id, statut) values (new.id, new.statut);
  end if;
  return new;
end;
$$ language plpgsql;

create trigger trg_commande_historique
after insert or update on commandes
for each row execute function fn_commande_log_historique();
