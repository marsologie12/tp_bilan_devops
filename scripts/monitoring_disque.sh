#!/bin/bash

# Nom : monitoring_disque.sh
# Description : Surveillance de l'espace disque

SEUIL=80
LOG="$(dirname "$0")/../logs/alertes_disque.log"

# Creation du dossier de logs si necessaire
mkdir -p "$(dirname "$LOG")" || exit 1

# Affichage de l'espace disque
df -h

# Recuperation du pourcentage utilise
UTILISATION=$(df -P / | tail -1 | awk '{print $5}' | tr -d '%')

# Verification des erreurs
if ! [[ "$UTILISATION" =~ ^[0-9]+$ ]]; then
    echo "Erreur : impossible de verifier le disque"
    exit 1
fi

# Verification du seuil
if [ "$UTILISATION" -ge "$SEUIL" ]; then
    MESSAGE="$(date '+%Y-%m-%d %H:%M:%S') - ALERTE : disque utilise a $UTILISATION%"

    echo "$MESSAGE"
    echo "$MESSAGE" >> "$LOG" || exit 1
else
    echo "OK : disque utilise a $UTILISATION%"
fi
