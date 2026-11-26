#!/bin/bash

# Nom : audit_utilisateur.sh
# Description : Surveillance des utilisateurs connectes

DEBUT=8
FIN=18
LOG="$(dirname "$0")/../logs/audit.log"

# Creation du dossier de logs
mkdir -p "$(dirname "$LOG")" || exit 1

# Recuperation de l'heure actuelle
HEURE=$(date +%-H)

# Recuperation des utilisateurs connectes
CONNEXIONS=$(who)

# Verification des erreurs
if [ $? -ne 0 ]; then
    echo "$(date) - ERREUR : commande who" >> "$LOG"
    exit 1
fi

# Affichage des utilisateurs connectes
echo "Utilisateurs connectes :"
echo "$CONNEXIONS"

# Enregistrement de la verification
echo "$(date) - Verification des connexions" >> "$LOG" || exit 1

# Verification de la presence de root
if echo "$CONNEXIONS" | grep -q "^root "; then

    # Verification de la plage horaire
    if [ "$HEURE" -lt "$DEBUT" ] || [ "$HEURE" -ge "$FIN" ]; then

        MESSAGE="$(date) - ALERTE : root connecte hors horaires"

        echo "$MESSAGE"
        echo "$MESSAGE" >> "$LOG" || exit 1

    else
        echo "OK : root connecte pendant les horaires autorises"
    fi

else
    echo "OK : aucune connexion root detectee"
fi
