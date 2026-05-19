# Osiris CI — Plateforme de Gestion GLPI 11

> Plateforme de helpdesk et gestion opérationnelle pour **Osiris CI**, intégrateur ERP (Sage X3, Sage 100, DIMO Maint FM) basé à Abidjan.

---

## 🌐 Accès

| Environnement | URL |
|---|---|
| **Production (Railway)** | https://osiris-ci-railway-production.up.railway.app |
| **Local** | http://localhost:7001/glpi |

---

## 🔑 Comptes de démonstration

> Mot de passe universel pour tous les comptes demo : **`Osiris2024!`**
> Compte super-admin : `glpi` / `glpi`

| Identifiant | Nom | Profil | Rôle métier |
|---|---|---|---|
| `glpi` | — | Super-Admin | Administration complète |
| `mariam.sangare` | Mariam SANGARÉ | Administration | Gestion utilisateurs, licences, exports |
| `ibrahima.toure` | Ibrahima TOURÉ | Responsable de Pôle | Validation PV, notes de frais, supervision |
| `fatoumata.diallo` | Fatoumata DIALLO | Dispatcher | Affectation des tickets entrants |
| `sekou.coulibaly` | Sékou COULIBALY | Consultant | Traitement tickets, log heures, PV |
| `adjoua.koffi` | Adjoua KOFFI | Commercial | Consultation tickets/coûts, export facturation |
| `konan.amani` | Amani KONAN | Utilisateur Client | Dépôt et suivi de tickets |
| `dsi.pamci` | Moussa TRAORÉ | Utilisateur Client | Client PAMCI |
| `erp.orange` | Aminata COULIBALY | Utilisateur Client | Client Orange CI |
| `compta.sogefi` | Koffi ASSOUAN | Utilisateur Client | Client SOGEFI |

---

## 📋 Formulaires publics (accès sans connexion)

| Formulaire | URL directe | Usage |
|---|---|---|
| Demande de création de compte | `/Form/Render/4?token=osiris-compte` | Nouveau client ou collaborateur |
| Signaler un incident | `/Form/Render/1?token=...` | Incident client |
| Demander un service | `/Form/Render/2?token=...` | Demande de prestation |
| Support ticket | `/Form/Render/3?token=...` | Ticket support générique |

---

## 🎭 Scénarios de démonstration

### Scénario 1 — Cycle de vie d'un ticket (vue complète)

**Objectif :** Montrer le flux de bout en bout depuis la demande client jusqu'à la facturation.

1. **Client dépose un ticket**
   - Se connecter avec `konan.amani` / `Osiris2024!`
   - Onglet "Créer un ticket" → Catégorie : Sage 100 > Anomalie/Bug
   - Décrire une anomalie de calcul de TVA dans Sage 100
   - Soumettre

2. **Dispatcher affecte le ticket**
   - Se connecter avec `fatoumata.diallo` / `Osiris2024!`
   - Voir le ticket en statut "Nouveau" dans son tableau de bord
   - Affecter au groupe "Consultants Sage 100" → Sékou Coulibaly
   - Statut passe à "En cours"

3. **Consultant traite et log ses heures**
   - Se connecter avec `sekou.coulibaly` / `Osiris2024!`
   - Voir le ticket assigné dans son tableau de bord
   - Ajouter un suivi technique + une tâche avec temps passé (2h)
   - Résoudre le ticket avec une solution documentée

4. **Responsable valide et clôture**
   - Se connecter avec `ibrahima.toure` / `Osiris2024!`
   - Voir le ticket résolu → approuver la solution
   - Vérifier les coûts enregistrés

5. **Commercial consulte pour facturation**
   - Se connecter avec `adjoua.koffi` / `Osiris2024!`
   - Tickets > filtrer par client SOGEFI + période
   - Export CSV des coûts pour Sage 100 Gestion Commerciale

---

### Scénario 2 — PV d'Intervention

**Objectif :** Montrer le processus de validation N+1 post-intervention.

1. **Consultant soumet un PV**
   - Connecté en `sekou.coulibaly`
   - Formulaire "PV d'Intervention" (menu Assistance > Formulaires)
   - Remplir : date, client, heures, travaux effectués, accord client
   - Soumettre → ticket "PV à valider" créé automatiquement

2. **Responsable valide**
   - Connecté en `ibrahima.toure`
   - Notification de validation dans le tableau de bord
   - Approuver (ou refuser avec motif)
   - PV archivé en document sur le ticket client

---

### Scénario 3 — Note de Frais

**Objectif :** Montrer le circuit de remboursement.

1. **Consultant dépose une note de frais**
   - Connecté en `sekou.coulibaly`
   - Formulaire "Note de Frais" → Type : Transport, Montant : 15 000 FCFA
   - Joindre le justificatif → Soumettre

2. **Responsable valide**
   - Connecté en `ibrahima.toure`
   - Approuver le montant

3. **Administration traite le paiement**
   - Connecté en `mariam.sangare`
   - Ticket reçu depuis le pôle RH → marquer payé

---

### Scénario 4 — Vue Client (portail helpdesk)

**Objectif :** Montrer ce que voit un client Osiris CI.

1. Se connecter avec `konan.amani` / `Osiris2024!`
2. Tableau de bord : uniquement ses propres tickets
3. Créer un nouveau ticket depuis le portail
4. Suivre l'avancement en temps réel

> Le client ne voit **pas** les tickets des autres clients, ni les coûts, ni les PV.

---

### Scénario 5 — Inscription client (formulaire public)

**Objectif :** Montrer l'onboarding d'un nouveau client sans compte.

1. Ouvrir en navigation privée : `https://osiris-ci-railway-production.up.railway.app/Form/Render/4?token=osiris-compte`
2. Remplir le formulaire (Prénom, Nom, Email pro, Société, Poste)
3. Soumettre → ticket de demande créé dans GLPI
4. Le Dispatcher voit la demande et crée le compte

---

## 👥 Profils et droits

| Profil | Tickets | Projets | Coûts | Licences | Validation | Utilisateurs |
|---|---|---|---|---|---|---|
| Super-Admin | Tout | Tout | Tout | Tout | Tout | Tout |
| Administration | Tout | Lecture | Tout | Tout | — | Gestion |
| Responsable de Pôle | Tout | Tout | Tout | Tout | PV + NDF | Lecture |
| Dispatcher | Voir + Affecter | Non | Non | Non | — | Non |
| Consultant | Ses tickets | Ses projets | Saisie | Lecture | — | Non |
| Commercial | Lecture | Lecture | Lecture | Lecture | — | Non |
| Utilisateur Client | Ses tickets | Non | Non | Non | — | Non |

---

## 🏢 Entités (Clients)

| Entité | Contacts demo |
|---|---|
| **Racine (Osiris CI)** | Tous les comptes internes |
| **SOGEFI** | `compta.sogefi`, `daf.sogefi` |
| **Orange CI** | `erp.orange`, `tresorerie.orange` |
| **PAMCI** | `dsi.pamci` |

---

## 🗂️ Catégories de tickets

```
├── Sage X3
│   ├── Anomalie / Bug
│   ├── Paramétrage
│   ├── Formation Sage X3
│   ├── Migration / Upgrade
│   └── Reporting & BI
├── Sage 100
│   ├── Anomalie / Bug
│   ├── Paramétrage
│   ├── Formation Sage 100
│   ├── Sage 100 Comptabilité
│   ├── Sage 100 Paie
│   └── Sage 100 Commercial
├── Infrastructure & Réseau
│   ├── Serveurs & Virtualisation
│   ├── Réseau & Connectivité
│   ├── Sécurité informatique
│   ├── Postes de travail
│   └── Messagerie & Bureautique
├── Développement & Applications
│   ├── Application Osiris
│   ├── Développement spécifique
│   ├── Interfaces & Connecteurs
│   └── Reprise de données
├── Audit & Conseil
├── Note de frais       (usage interne)
└── PV d'Intervention   (usage interne)
```

---

## 🏗️ Architecture technique

```
Railway Cloud
├── osiris-ci-railway   (Docker — PHP 8.3 / Apache / GLPI 11.0.7)
│   └── Image : diouxx/glpi:latest + GLPI 11.0.7 figé au build
└── MySQL 9.4           (Railway managed DB)
    └── Base : railway (124 tables, dump Osiris CI)

GitHub : Brackford-0brien/osiris-ci-railway
```

### Variables Railway (service osiris-ci-railway)
```
MYSQLHOST      = mysql.railway.internal
MYSQLPORT      = 3306
MYSQLUSER      = root
MYSQLPASSWORD  = [voir Railway dashboard]
MYSQLDATABASE  = railway
```

---

## 🔄 Redéploiement

```bash
# Modifier les fichiers dans railway-deploy/
cd C:/Users/Administrateur/glpi/railway-deploy
git add . && git commit -m "message" && git push
# Railway redéploie automatiquement depuis GitHub
```

### Import base de données
```bash
docker exec -i glpi-db mysql -h shuttle.proxy.rlwy.net -P 24422 \
  -u root -p<PASSWORD> railway < build/osiris_dump.sql
```
