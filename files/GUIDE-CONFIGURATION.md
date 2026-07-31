# Goly Express — Guide de configuration (Phase 1 : parcours client)

Ce dossier contient le site client (réservation + suivi en direct) branché sur une vraie base de données. Il te reste **3 étapes** pour que tout fonctionne.

## Fichiers du dossier
- `index.html` — page d'accueil + formulaire de réservation
- `suivi.html` — page de suivi en temps réel (carte + statut)
- `manifest.json` + `sw.js` + `icon-192.png` / `icon-512.png` — rendent le site installable comme une app
- `supabase-schema.sql` — structure de la base de données à installer

---

## Étape 1 — Créer le projet Supabase (5 minutes, gratuit)

1. Va sur **https://supabase.com** → "Start your project" → connecte-toi avec GitHub ou email
2. Crée un nouveau projet : nom `goly-express`, choisis un mot de passe pour la base (à conserver), région la plus proche (Europe de l'Ouest recommandé)
3. Attends 1-2 minutes que le projet soit prêt

## Étape 2 — Installer la base de données

1. Dans le menu de gauche, clique sur **SQL Editor** → **New query**
2. Ouvre le fichier `supabase-schema.sql` de ce dossier, copie tout son contenu, colle-le dans l'éditeur
3. Clique sur **Run** (ou Ctrl+Entrée)
4. Tu dois voir "Success. No rows returned" → la base est prête (tables `clients`, `coursiers`, `commandes`, `historique_statuts`, `zones_tarifs`)

## Étape 3 — Connecter le site à la base

1. Dans Supabase, va dans **Project Settings** (icône engrenage) → **API**
2. Copie l'**URL du projet** (ex: `https://xxxxxxxx.supabase.co`)
3. Copie la clé **anon public** (⚠️ pas la clé `service_role`, celle-là ne doit jamais apparaître dans le site)
4. Ouvre `index.html`, cherche la section `CONFIG` (utilise Ctrl+F), colle tes valeurs :
   ```js
   const CONFIG = {
     SUPABASE_URL: "https://xxxxxxxx.supabase.co",
     SUPABASE_ANON_KEY: "eyJhbGci...",
     WHATSAPP_ADMIN_NUMBER: "2250502829764"
   };
   ```
5. Fais la même chose dans `suivi.html` (section `CONFIG` en bas du fichier)

## Étape 4 — Mettre le site en ligne

Le plus simple et gratuit : **Netlify** ou **Vercel**.
- Sur https://app.netlify.com/drop, glisse-dépose tout le dossier → le site est en ligne en 30 secondes avec une adresse `https://xxxx.netlify.app`
- Tu pourras ensuite brancher ton propre nom de domaine (ex: `golyexpress.ci`) dans les réglages Netlify

---

## Comment tester

1. Ouvre le site en ligne, passe une commande test dans le formulaire
2. Tu es redirigé vers un bouton "Suivre ma commande en direct"
3. Pour simuler le travail de l'admin/livreur (en attendant la Phase 3, le tableau de bord admin) : va dans Supabase → **Table Editor** → table `commandes` → modifie la colonne `statut` de ta commande test (`en_attente` → `coursier_affecte` → `en_route` → `livre`)
4. La page de suivi se met à jour **automatiquement, sans rafraîchir** — c'est le temps réel de Supabase en action

---

## Et après ? (prochaines phases)

- **Phase 2 — App/interface livreur** : un espace où le coursier se connecte, voit les courses qui lui sont affectées, met à jour son statut et partage sa position GPS en direct (ce qui fera bouger le point orange sur la carte du client automatiquement)
- **Phase 3 — Back-office admin** : tableau de bord pour affecter les commandes aux coursiers, suivre l'activité, gérer les tarifs par zone
- **Phase 4 — Paiement en ligne** : intégration d'un agrégateur mobile money (CinetPay, PayDunya ou Wave) une fois le compte business ouvert

Dis-moi quand tu es prêt et on enchaîne sur la Phase 2 (app livreur).
