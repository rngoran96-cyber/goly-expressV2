-- ============================================================
-- GOLY EXPRESS — Migration Phase 3 (back-office admin)
-- ============================================================
-- À exécuter dans Supabase > SQL Editor, APRÈS Phase 1 et Phase 2.
-- ============================================================

-- L'admin doit pouvoir ajouter de nouveaux coursiers depuis le tableau de bord
create policy "public_insert_coursier" on coursiers
  for insert to anon with check (true);

-- L'admin doit pouvoir modifier / ajouter les zones tarifaires
create policy "public_update_zones" on zones_tarifs
  for update to anon using (true) with check (true);

create policy "public_insert_zones" on zones_tarifs
  for insert to anon with check (true);

-- ⚠️ Rappel de sécurité (comme en Phase 2) :
-- Ces autorisations restent ouvertes à toute personne connaissant la clé "anon"
-- (visible dans le code source du site). Le mot de passe demandé dans admin.html
-- protège l'ACCÈS À L'INTERFACE, mais pas la base de données elle-même.
-- C'est un compromis correct pour démarrer sans données bancaires sensibles.
-- Quand Goly Express grandira, prévoir une vraie authentification Supabase Auth
-- avec des rôles (admin / coursier / client) pour verrouiller ça proprement.
