# Documentation - Monitoring disque

## 1. Présentation

Le script monitoring_disque.sh permet de surveiller
l'espace disque utilisé sur un serveur Linux.

L'objectif est d'éviter qu'un disque soit saturé,
ce qui pourrait provoquer des ralentissements ou
des problèmes de fonctionnement du serveur.

Lorsque le disque atteint 80 % d'utilisation,
une alerte est affichée et enregistrée dans un
fichier de logs.

## 2. Choix technique

J'ai choisi Bash car il permet d'utiliser directement
les commandes Linux sans installer de bibliothèques
supplémentaires.

Le script a été développé et testé sous WSL.

## 3. Utilisation

Donner les droits d'exécution au script :

    chmod +x scripts/monitoring_disque.sh

Exécuter le script :

    ./scripts/monitoring_disque.sh

Il est également possible de l'exécuter avec Bash :

    bash scripts/monitoring_disque.sh

## 4. Paramètres

Le seuil d'alerte est défini dans le script :

    SEUIL=80

Cette variable permet de définir le pourcentage
d'utilisation à partir duquel une alerte est générée.

Le script surveille la partition principale /.

Le seuil peut être modifié directement dans le script.

## 5. Explication des commandes utilisées

| Commande | Explication |
|---|---|
| df -h | Affiche l'espace disque dans un format lisible. |
| df -P / | Récupère les informations de la partition principale. |
| tail -1 | Récupère la dernière ligne du résultat. |
| awk '{print $5}' | Récupère la cinquième colonne, qui contient le pourcentage utilisé. |
| tr -d '%' | Supprime le symbole %. |
| date | Récupère la date et l'heure. |
| echo | Affiche un message. |
| mkdir -p | Crée un dossier s'il n'existe pas. |
| dirname | Récupère le chemin du dossier parent d'un fichier. |
| exit 1 | Arrête le script en signalant une erreur. |

## 6. Fonctionnement du script

Le script fonctionne en plusieurs étapes :

1. Il définit le seuil d'alerte à 80 %.
2. Il vérifie que le dossier logs existe.
3. Il affiche l'espace disque disponible et utilisé.
4. Il récupère le pourcentage utilisé sur la partition principale.
5. Il vérifie que la valeur récupérée est un nombre.
6. Il compare cette valeur avec le seuil.
7. Si le seuil est atteint, il génère une alerte.
8. Sinon, il affiche que l'utilisation du disque est normale.

La condition -ge signifie supérieur ou égal.

L'opérateur >> permet d'ajouter du texte à la fin
d'un fichier sans supprimer son contenu existant.

## 7. Gestion des erreurs

Le script vérifie que le pourcentage récupéré
est bien une valeur numérique.

Si une erreur est détectée, le script affiche
un message et s'arrête avec exit 1.

Il vérifie également la création du dossier de logs
et l'écriture dans le fichier d'alertes.

## 8. Journalisation

Les alertes sont enregistrées dans :

    logs/alertes_disque.log

Pour consulter les alertes :

    cat logs/alertes_disque.log

Un log est un fichier qui conserve un historique
des événements afin de faciliter la surveillance
et le diagnostic des problèmes.

## 9. Scénarios de test

### Test 1 - Fonctionnement normal

Exécuter le script avec un seuil de 80 % :

    ./scripts/monitoring_disque.sh

Résultat attendu si le disque est utilisé à moins
de 80 % :

    OK : disque utilise a 15%

### Test 2 - Déclenchement d'une alerte

Modifier temporairement le seuil :

    SEUIL=1

Exécuter le script :

    ./scripts/monitoring_disque.sh

Résultat attendu si le disque est utilisé
à au moins 1 % :

    ALERTE : disque utilise a 15%

Vérifier que l'alerte est enregistrée :

    cat logs/alertes_disque.log

Après le test, remettre le seuil à 80 %.

### Test 3 - Vérification de la syntaxe

    bash -n scripts/monitoring_disque.sh

Si aucun message ne s'affiche, la syntaxe
du script est correcte.

## 10. Automatisation avec Cron

Cron est un service Linux permettant d'exécuter
automatiquement des commandes à des horaires définis.

Installation et démarrage :

    sudo apt install cron -y
    sudo service cron start

Modification des tâches planifiées :

    crontab -e

Configuration utilisée :

    */5 * * * * /bin/bash /home/mars/tp_bilan_devops/scripts/monitoring_disque.sh

Le script est exécuté automatiquement toutes
les cinq minutes.

Sous WSL, Cron doit être actif pour que les tâches
planifiées puissent fonctionner.

## 11. Sécurisation

Les permissions du script sont définies avec :

    chmod 750 scripts/monitoring_disque.sh

Le propriétaire possède les droits de lecture,
d'écriture et d'exécution.

Le groupe possède les droits de lecture et d'exécution.

Les autres utilisateurs ne possèdent aucun droit.

Le dossier logs est également protégé :

    chmod 700 logs/

Les logs ne sont pas envoyés sur GitHub grâce
au fichier .gitignore.

## 12. Limites et améliorations possibles

Le script surveille uniquement la partition principale.

Il serait possible de l'améliorer en ajoutant :

- La surveillance de toutes les partitions.
- Un seuil configurable depuis la ligne de commande.
- L'envoi d'un email en cas d'alerte.
- Plusieurs niveaux d'alerte.

## 13. Conclusion

Ce script permet d'automatiser la surveillance
de l'espace disque d'un serveur Linux.

Il permet de détecter un risque de saturation
et de conserver un historique des alertes.

L'utilisation de Cron évite de devoir lancer
manuellement le script.
