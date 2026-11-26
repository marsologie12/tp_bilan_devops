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