## Automatisation des tâches récurrentes d'administration système

### 1. Objectif
Afin de garantir la disponibilité des services, de prévenir les incidents d'exploitation et de réduire les risques liés aux interventions manuelles, les tâches d'administration courantes doivent être automatisées selon une politique standardisée.

---

### 2. Périmètre des tâches automatisées

#### 2.1. Sauvegardes et externalisation
* **Objectif :** Assurer l'intégrité et la disponibilité des données critiques (bases de données, fichiers de configuration, volumes applicatifs) en vue d'une reprise d'activité (PRA/PCA).
* **Fonctionnement :** Exécution planifiée de sauvegardes incrémentales et chiffrées, suivie d'un transfert automatique vers un stockage distant et d'un contrôle périodique de l'intégrité des archives.

#### 2.2. Rotation et rétention des journaux (Logs)
* **Objectif :** Prévenir la saturation des systèmes de fichiers tout en conservant un historique exploitable pour le diagnostic et les audits de sécurité.
* **Fonctionnement :** Compression, archivage et purge automatique des fichiers journaux (système et applicatifs) selon des seuils définis de taille ou de durée de rétention.

#### 2.3. Gestion des correctifs de sécurité
* **Objectif :** Réduire la fenêtre d'exposition de l'infrastructure face aux vulnérabilités connues.
* **Fonctionnement :** Vérification et installation automatisées des mises à jour critiques sur les systèmes d'exploitation et les environnements applicatifs, avec journalisation des opérations et redémarrage contrôlé si nécessaire.

---

### 3. Tableau récapitulatif

| Tâche | Fréquence recommandée | Risque couvert |
| :--- | :--- | :--- |
| **Sauvegardes** | Quotidienne | Perte de données, sinistre, ransomware |
| **Rotation des logs** | Quotidienne / Hebdomadaire | Saturation disque, perte de traçabilité |
| **Mises à jour de sécurité** | Quotidienne / Hebdomadaire | Exploitation de vulnérabilités (CVE) |

