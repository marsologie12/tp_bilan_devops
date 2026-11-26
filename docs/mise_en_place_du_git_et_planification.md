# Automatisation des tâches récurrentes d'administration système

## 1. Objectif

Afin de garantir la disponibilité des services, de prévenir les incidents d'exploitation et de réduire les risques liés aux interventions manuelles, les tâches d'administration courantes doivent être automatisées selon une politique standardisée.

---

## 2. Périmètre des tâches automatisées

### 2.1. Sauvegardes et externalisation (Backups)

* **Objectif :** Assurer l'intégrité et la disponibilité des données critiques (bases de données, fichiers de configuration, volumes applicatifs) en vue d'une reprise d'activité (PRA/PCA).
* **Fonctionnement :** Exécution planifiée de sauvegardes incrémentales et chiffrées, suivie d'un transfert automatique vers un stockage distant et d'un contrôle périodique de l'intégrité des archives.
* **Outils standards :** `BorgBackup`, `Restic`, `rsync`, ordonnancés via `systemd timers` ou `cron`.

### 2.2. Rotation et rétention des journaux (Log Rotation)

* **Objectif :** Prévenir la saturation des systèmes de fichiers tout en conservant un historique exploitable pour le diagnostic et les audits de sécurité.
* **Fonctionnement :** Compression, archivage et purge automatique des fichiers journaux (`/var/log` et logs applicatifs) selon des seuils définis de taille ou de durée de rétention.
* **Outils standards :** `logrotate`, gestionnaires de logs centralisés (Rsyslog, Loki, ELK).

### 2.3. Gestion des correctifs de sécurité (Patch Management)

* **Objectif :** Réduire la fenêtre d'exposition de l'infrastructure face aux vulnérabilités connues.
* **Fonctionnement :** Vérification et installation automatisées des mises à jour critiques sur les systèmes d'exploitation et les environnements conteneurisés, avec journalisation des opérations et redémarrage contrôlé si nécessaire.
* **Outils standards :** `unattended-upgrades` (Debian/Ubuntu), playbooks `Ansible` planifiés, `Watchtower` (environnements Docker).

---

## 3. Tableau récapitulatif

| Tâche | Fréquence recommandée | Outils de référence | Risque couvert |
| :--- | :--- | :--- | :--- |
| **Sauvegardes** | Quotidienne | `Restic`, `BorgBackup`, `cron` | Perte de données, sinistre, ransomware |
| **Rotation des logs** | Quotidienne / Hebdomadaire | `logrotate` | Saturation disque, perte de traçabilité |
| **Mises à jour de sécurité** | Quotidienne / Hebdomadaire | `unattended-upgrades`, `Ansible` | Exploitation de vulnérabilités (CVE) |

## 4. Choix techniques retenus

Pour réaliser ce projet, nous avons choisi d'utiliser WSL.
Cet outil permet d'utiliser un environnement Linux directement
sur Windows, sans installer une machine virtuelle classique.

### Surveillance de l'espace disque

- Script : monitoring_disque.sh
- Langage : Bash
- Outils : df, awk, grep, date

Nous avons choisi Bash car il permet d'utiliser directement
les commandes Linux. Le script vérifie l'espace disque utilisé
et génère une alerte lorsque le seuil de 80 % est atteint.
Les alertes sont enregistrées dans un fichier de logs.

### Sauvegarde automatique

- Script : backup.py
- Langage : Python
- Bibliothèques : os, shutil, sys, datetime

Nous avons choisi Python car il facilite la manipulation
des fichiers et des répertoires ainsi que la gestion des erreurs.
Il permet également d'ajouter la date et l'heure au nom
de chaque sauvegarde et de simuler l'envoi d'un email.

### Rotation et nettoyage des logs

- Script : log_rotate.sh
- Langage : Bash
- Outils prévus : find, stat, cp, truncate, date

Bash permet de gérer facilement les fichiers présents sur
un serveur Linux. Le script permettra d'archiver les logs
trop volumineux et de supprimer les anciennes archives
selon des paramètres définis par l'utilisateur.

### Audit utilisateur

- Script : audit_utilisateur.sh
- Langage : Bash
- Outils prévus : who, grep, date

Nous avons choisi Bash car Linux possède déjà des commandes
permettant de connaître les utilisateurs connectés.
Le script permettra également de générer une alerte si
l'utilisateur root est connecté en dehors des horaires autorisés.

## 5. Répartition du travail

Ce projet est réalisé en binôme.

Pour ma part, je suis responsable de :

- La réalisation du script monitoring_disque.sh.
- La réalisation du script complémentaire audit_utilisateur.sh.
- Les tests de fonctionnement de mes scripts.
- Les choix techniques retenus pour chaque tâche.
- L'organisation du dépôt Git.

## 6. Organisation du dépôt Git

Nous avons créé un dépôt GitHub commun afin de travailler
à deux, de partager nos scripts et de conserver un historique
des modifications.

### Structure des répertoires

    tp_bilan_devops/
    ├── docs/
    │   └── partie1.md
    ├── scripts/
    │   ├── monitoring_disque.sh
    │   ├── backup.py
    │   ├── log_rotate.sh
    │   └── audit_utilisateur.sh
    ├── logs/
    ├── sauvegardes/
    ├── tests/
    ├── .gitattributes
    ├── .gitignore
    └── README.md

### Rôle des répertoires et fichiers

| Nom | Description |
|---|---|
| scripts/ | Contient les scripts Bash et Python. |
| docs/ | Contient la documentation du projet. |
| logs/ | Contient les journaux et les alertes. |
| sauvegardes/ | Contient les sauvegardes générées. |
| tests/ | Contient les fichiers utilisés pour les tests. |
| README.md | Présente le projet et son fonctionnement. |
| .gitignore | Exclut les fichiers qui ne doivent pas être publiés. |
| .gitattributes | Permet notamment de conserver les fins de ligne Linux. |
| .gitkeep | Permet de conserver les répertoires vides sur GitHub. |

### Conventions de nommage

Pour garder un projet propre et compréhensible, nous avons
défini plusieurs règles :

- Utiliser des noms de fichiers en minuscules.
- Ne pas utiliser d'espaces ni d'accents.
- Séparer les mots avec un underscore (_).
- Utiliser l'extension .sh pour les scripts Bash.
- Utiliser l'extension .py pour les scripts Python.
- Utiliser l'extension .md pour la documentation.
- Rédiger les commentaires en français.
- Utiliser des messages de commit clairs.

### Travail collaboratif avec Git

Nous utilisons plusieurs commandes Git pour travailler
sur le même projet :

| Commande | Utilité |
|---|---|
| git clone | Récupérer le dépôt GitHub. |
| git status | Vérifier les modifications locales. |
| git add | Sélectionner les fichiers à enregistrer. |
| git commit | Enregistrer une modification dans l'historique. |
| git pull --rebase | Récupérer les modifications du binôme. |
| git push | Envoyer les modifications sur GitHub. |

Les fichiers de sauvegarde et les logs générés ne sont pas
publiés sur GitHub pour éviter de partager des données
potentiellement confidentielles.
