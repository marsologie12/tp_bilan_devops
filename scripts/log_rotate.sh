#!/bin/bash
# Nom : log_rotate.sh
# Description : Rotation (compression) et purge des fichiers logs d'un dossier selon leur âge (en jours) ou leur taille

# Arrêt immédiat en cas d'erreur de commande ou de variable non définie
set -euo pipefail

# --- Configuration globale ---
FICHIER_LOG="log_rotate.log"

# Fonction de journalisation (affiche dans la console ET écrit dans le fichier log)
log_message() {
    local niveau="$1"
    local message="$2"
    local horodatage
    horodatage=$(date "+%Y-%m-%d %H:%M:%S")
    echo "$horodatage [$niveau] $message" | tee -a "$FICHIER_LOG"
}

# Affichage de l'aide d'utilisation
usage() {
    echo "Usage : $0 <dossier_logs> <age_max_jours> <taille_max>"
    echo "Exemple : $0 /var/log/mon_app 7 10M"
    echo "  - age_max_jours : Supprime les archives de plus de X jours (ex: 7)"
    echo "  - taille_max    : Compresse/purge les logs dépassant cette taille (ex: 500k, 10M, 1G)"
    exit 1
}

# --- 1. Vérification des paramètres ---
if [ "$#" -ne 3 ]; then
    log_message "WARNING" "Nombre d'arguments invalide."
    usage
fi

DOSSIER_LOGS="$1"
AGE_MAX_JOURS="$2"
TAILLE_MAX="$3"

# Vérification de l'existence du dossier cible
if [ ! -d "$DOSSIER_LOGS" ]; then
    log_message "ERROR" "Le dossier '$DOSSIER_LOGS' n'existe pas ou n'est pas un répertoire."
    exit 1
fi

# Vérification que l'âge est bien un nombre entier positif
if ! [[ "$AGE_MAX_JOURS" =~ ^[0-9]+$ ]]; then
    log_message "ERROR" "L'âge maximum doit être un nombre entier de jours (reçu : '$AGE_MAX_JOURS')."
    exit 1
fi

log_message "INFO" "Démarrage de la rotation des logs dans '$DOSSIER_LOGS' (Age max: ${AGE_MAX_JOURS}j, Taille max: ${TAILLE_MAX})."

# --- 2. Rotation (compression) des fichiers .log actifs ---
TIMESTAMP=$(date "+%Y%m%d_%H%M%S")
compteur_rotation=0

# On parcourt uniquement les fichiers .log à la racine du dossier donné
while IFS= read -r -d '' fichier; do
    nom_base=$(basename "$fichier")
    archive="${fichier}.${TIMESTAMP}.gz"

    # Compresse le contenu du log dans une archive .gz puis vide le fichier actif (copytruncate)
    # Cela évite de casser les applications qui écrivent encore dedans
    if gzip -c "$fichier" > "$archive" && : > "$fichier"; then
        log_message "INFO" "Rotation effectuée : '$nom_base' -> '$(basename "$archive")'"
        ((compteur_rotation++)) || true
    else
        log_message "ERROR" "Échec de la rotation pour '$nom_base'."
    fi
done < <(find "$DOSSIER_LOGS" -maxdepth 1 -type f -name "*.log" -size +"$TAILLE_MAX" -print0 2>/dev/null || true)

if [ "$compteur_rotation" -eq 0 ]; then
    log_message "INFO" "Aucun fichier .log actif ne dépasse la taille de $TAILLE_MAX."
fi

# --- 3. Purge des anciennes archives (.gz) par âge ---
compteur_purge_age=0

while IFS= read -r -d '' vieille_archive; do
    if rm -f "$vieille_archive"; then
        log_message "INFO" "Archive supprimée (âge > ${AGE_MAX_JOURS} jours) : '$(basename "$vieille_archive")'"
        ((compteur_purge_age++)) || true
    else
        log_message "ERROR" "Impossible de supprimer '$vieille_archive'."
    fi
done < <(find "$DOSSIER_LOGS" -maxdepth 1 -type f -name "*.log.*.gz" -mtime +"$AGE_MAX_JOURS" -print0 2>/dev/null || true)

# --- 4. Purge des archives (.gz) dépassant la taille maximale ---
compteur_purge_taille=0

while IFS= read -r -d '' archive_lourde; do
    if rm -f "$archive_lourde"; then
        log_message "INFO" "Archive supprimée (taille > ${TAILLE_MAX}) : '$(basename "$archive_lourde")'"
        ((compteur_purge_taille++)) || true
    else
        log_message "ERROR" "Impossible de supprimer '$archive_lourde'."
    fi
done < <(find "$DOSSIER_LOGS" -maxdepth 1 -type f -name "*.log.*.gz" -size +"$TAILLE_MAX" -print0 2>/dev/null || true)

log_message "INFO" "Traitement terminé. Rotations : $compteur_rotation | Purges âge : $compteur_purge_age | Purges taille : $compteur_purge_taille."
exit 0
