# Documentation - Audit utilisateur

## 1. Présentation

Le script audit_utilisateur.sh permet de surveiller
les utilisateurs connectés sur un serveur Linux.

Son objectif principal est de détecter les connexions
de l'utilisateur root en dehors des horaires autorisés.

Une alerte est générée si une session root est détectée
entre 18h00 et 8h00.

## 2. Choix technique

J'ai choisi Bash car Linux possède déjà des commandes
permettant de récupérer les utilisateurs connectés
ainsi que la date et l'heure.

Il n'est donc pas nécessaire d'installer
des bibliothèques supplémentaires.

Le script a été développé et testé sous WSL.

## 3. Utilisation

Donner les droits d'exécution au script :

    chmod +x scripts/audit_utilisateur.sh

Exécuter le script :

    ./scripts/audit_utilisateur.sh

Il est également possible de l'exécuter avec Bash :

    bash scripts/audit_utilisateur.sh

## 4. Paramètres

Les horaires autorisés sont définis dans le script :

    DEBUT=8
    FIN=18

La plage horaire autorisée est donc comprise
entre 8h00 inclus et 18h00 exclu.

Ces variables peuvent être modifiées directement
dans le script selon les besoins de l'entreprise.

## 5. Explication des commandes utilisées

| Commande | Explication |
|---|---|
| who | Affiche les sessions utilisateurs enregistrées. |
| whoami | Affiche le nom de l'utilisateur actuel. |
| date +%-H | Récupère l'heure actuelle au format 24 heures. |
| grep | Recherche un texte dans un résultat. |
| grep -q | Effectue une recherche sans afficher le résultat. |
| echo | Affiche un message. |
| mkdir -p | Crée un dossier s'il n'existe pas. |
| dirname | Récupère le chemin du dossier parent d'un fichier. |
| exit 1 | Arrête le script en signalant une erreur. |

## 6. Explication des termes techniques

### Root

Root est le compte administrateur principal de Linux.

Il possède des droits élevés sur le système.
Il est donc important de surveiller son utilisation.

### Audit utilisateur

Un audit utilisateur consiste à vérifier
les activités et les connexions des utilisateurs
afin de détecter des comportements inhabituels.

### Journalisation

La journalisation consiste à enregistrer
des événements dans un fichier de logs.

Elle permet de conserver un historique
des vérifications et des alertes.

## 7. Fonctionnement du script

Le script fonctionne en plusieurs étapes :

1. Il définit les horaires autorisés.
2. Il vérifie que le dossier logs existe.
3. Il récupère l'heure actuelle.
4. Il récupère la liste des utilisateurs connectés.
5. Il affiche les utilisateurs détectés.
6. Il recherche une connexion root.
7. Il vérifie si l'heure actuelle est autorisée.
8. Il génère une alerte si root est connecté hors horaires.
9. Il enregistre les vérifications et les alertes.

### Explication de la condition

    grep -q "^root "

Cette commande recherche une ligne qui commence
par le nom root.

Le symbole ^ représente le début d'une ligne.

### Explication des opérateurs

| Opérateur | Signification |
|---|---|
| -lt | Strictement inférieur. |
| -ge | Supérieur ou égal. |
| -ne | Différent de. |
| || | OU logique. |
| $? | Code de retour de la dernière commande. |
| >> | Ajoute du contenu à la fin d'un fichier. |

La condition suivante vérifie si l'heure actuelle
est en dehors des horaires autorisés :

    [ "$HEURE" -lt "$DEBUT" ] || [ "$HEURE" -ge "$FIN" ]

Si l'heure est inférieure à 8h00 ou supérieure
ou égale à 18h00, la condition est vraie.

## 8. Gestion des erreurs

Le script vérifie le bon fonctionnement
de la commande who.

Si cette commande rencontre une erreur,
un message est enregistré dans le fichier de logs
et le script s'arrête avec exit 1.

Le script vérifie également la création
du dossier de logs et l'écriture des alertes.

## 9. Journalisation

Les vérifications et les alertes sont enregistrées dans :

    logs/audit.log

Pour consulter le fichier :

    cat logs/audit.log

Pour surveiller les nouvelles lignes en temps réel :

    tail -f logs/audit.log

## 10. Scénarios de test

### Test 1 - Aucun utilisateur root connecté

Exécuter le script :

    ./scripts/audit_utilisateur.sh

Résultat attendu :

    OK : aucune connexion root detectee

### Test 2 - Root connecté pendant les horaires autorisés

Si une session root est enregistrée par who
entre 8h00 et 18h00, le résultat attendu est :

    OK : root connecte pendant les horaires autorises

### Test 3 - Root connecté en dehors des horaires autorisés

Sous WSL, la commande who ne détecte pas toujours
les sessions ouvertes dans un terminal.

Pour tester l'alerte, il est possible de simuler
une connexion root à 23h00.

    (
        who() { echo "root pts/0"; }
        date() {
            if [ "$1" = "+%-H" ]; then
                echo 23
            else
                command date "$@"
            fi
        }
        export -f who date
        bash scripts/audit_utilisateur.sh
    )

Résultat attendu :

    ALERTE : root connecte hors horaires

Cette simulation ne modifie ni l'heure du système
ni le contenu du script.

### Test 4 - Vérification des logs

    cat logs/audit.log

Les vérifications et les alertes doivent être
présentes dans le fichier.

### Test 5 - Vérification de la syntaxe

    bash -n scripts/audit_utilisateur.sh

Si aucun message ne s'affiche, la syntaxe
du script est correcte.

## 11. Automatisation avec Cron

Cron permet d'exécuter automatiquement le script
sans intervention humaine.

Installation et démarrage :

    sudo apt install cron -y
    sudo service cron start

Configuration :

    crontab -e

Tâche planifiée :

    */10 * * * * /bin/bash /home/mars/tp_bilan_devops/scripts/audit_utilisateur.sh

Le script est exécuté automatiquement toutes
les dix minutes.

Pour vérifier les tâches planifiées :

    crontab -l

## 12. Sécurisation

Les permissions du script sont définies avec :

    chmod 750 scripts/audit_utilisateur.sh

Cette configuration limite l'accès au script
au propriétaire et aux membres de son groupe.

Le dossier logs est également protégé :

    chmod 700 logs/

Les fichiers de logs sont exclus du dépôt GitHub
grâce au fichier .gitignore.

Cela permet d'éviter de publier des informations
potentiellement confidentielles.

## 13. Limites et améliorations possibles

La commande who ne détecte pas toutes les sessions
utilisateurs sous WSL.

Elle ne permet pas non plus de détecter toutes
les utilisations de sudo ou du compte root.

Le script vérifie les sessions présentes au moment
de son exécution et non toutes les connexions passées.

Plusieurs améliorations sont possibles :

- Analyser les journaux d'authentification Linux.
- Détecter les tentatives de connexion échouées.
- Surveiller les connexions SSH.
- Envoyer un email en cas d'alerte.
- Ajouter plusieurs utilisateurs à surveiller.

## 14. Conclusion

Ce script permet d'automatiser la surveillance
des sessions utilisateurs sur un serveur Linux.

Il contribue à la sécurité du système en signalant
les connexions root en dehors des horaires autorisés.

La journalisation permet de conserver un historique
et de faciliter la recherche d'événements suspects.
