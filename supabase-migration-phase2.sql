-- ============================================================
-- GOLY EXPRESS — Migration Phase 2 (app livreur)
-- ============================================================
-- À exécuter dans Supabase > SQL Editor, APRÈS avoir déjà installé
-- supabase-schema.sql (Phase 1). Ne fais tourner ce fichier qu'UNE fois.
-- ============================================================

-- Code secret à 4 chiffres pour la connexion du coursier (simple, adapté au terrain)
alter table coursiers add column if not exists pin_code text;

-- ------------------------------------------------------------
-- Autorisations pour que l'app livreur puisse fonctionner
-- ------------------------------------------------------------
-- ⚠️ Note de sécurité importante :
-- Le code PIN protège l'accès dans l'app, mais la base de données elle-même
-- reste ouverte en écriture pour la clé "anon" (nécessaire en l'absence d'un
-- vrai système de compte Supabase Auth). C'est un compromis raisonnable pour
-- démarrer (aucune donnée bancaire n'est en jeu), à faire évoluer plus tard
-- vers une authentification réelle par coursier quand le volume grandira.

-- Un coursier peut mettre à jour sa propre position et son statut (disponible/en_course/hors_ligne)
create policy "public_update_coursier" on coursiers
  for update to anon using (true) with check (true);

-- Un coursier peut s'auto-affecter une commande en attente, et faire avancer le statut
create policy "public_update_commande" on commandes
  for update to anon using (true) with check (true);
