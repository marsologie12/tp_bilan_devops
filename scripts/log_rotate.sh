#!/bin/bash
# Nom : log_rotate.sh
# Description : Rotation (compression) et purge automatisée des logs (défaut : ./logs, 180 jours, 50 Mo)

set -euo pipefail

# --- Configuration par défaut (paramétrable via arguments optionnels) ---
DOSSIER_LOGS="${1:-./logs}"
AGE_MAX_JOURS="${2:-180}"
TAILLE_MAX="${3:-50M}"
FICHIER_LOG="log_rotate.log"

# Fonction de journalisation (console + fichier log)
log_message() {
    local niveau="$1"
    local message="$2"
    local horodatage
    horodatage=$(date "+%Y-%m-%d %H:%M:%S")
    echo "$horodatage [$niveau] $message" | tee -a "$FICHIER_LOG"
}

# --- 1. Contrôles préalables ---
if [ ! -d "$DOSSIER_LOGS" ]; then
    log_message "ERROR" "Le dossier '$DOSSIER_LOGS' n'existe pas ou n'est pas un répertoire."
    exit 1
fi

if ! [[ "$AGE_MAX_JOURS" =~ ^[0-9]+$ ]]; then
    log_message "ERROR" "L'âge maximum doit être un entier positif (reçu : '$AGE_MAX_JOURS')."
    exit 1
fi

log_message "INFO" "Démarrage rotation dans '$DOSSIER_LOGS' (Rétention: ${AGE_MAX_JOURS}j | Taille max: ${TAILLE_MAX})."

# --- 2. Rotation (compression) des fichiers .log actifs > 50M ---
TIMESTAMP=$(date "+%Y%m%d_%H%M%S")
compteur_rotation=0

while IFS= read -r -d '' fichier; do
    nom_base=$(basename "$fichier")
    archive="${fichier}.${TIMESTAMP}.gz"

    if gzip -c "$fichier" > "$archive" && : > "$fichier"; then
        log_message "INFO" "Rotation effectuée : '$nom_base' -> '$(basename "$archive")'"
        ((compteur_rotation++)) || true
    else
        log_message "ERROR" "Échec de la rotation pour '$nom_base'."
    fi
done < <(find "$DOSSIER_LOGS" -maxdepth 1 -type f -name "*.log" -size +"$TAILLE_MAX" -print0 2>/dev/null || true)

# --- 3. Purge des anciennes archives (.gz) > 180 jours ---
compteur_purge_age=0

while IFS= read -r -d '' vieille_archive; do
    if rm -f "$vieille_archive"; then
        log_message "INFO" "Archive supprimée (âge > ${AGE_MAX_JOURS}j) : '$(basename "$vieille_archive")'"
        ((compteur_purge_age++)) || true
    else
        log_message "ERROR" "Impossible de supprimer '$vieille_archive'."
    fi
done < <(find "$DOSSIER_LOGS" -maxdepth 1 -type f -name "*.log.*.gz" -mtime +"$AGE_MAX_JOURS" -print0 2>/dev/null || true)

# --- 4. Purge des archives (.gz) dépassant 50M ---
compteur_purge_taille=0

while IFS= read -r -d '' archive_lourde; do
    if rm -f "$archive_lourde"; then
        log_message "INFO" "Archive supprimée (taille > ${TAILLE_MAX}) : '$(basename "$archive_lourde")'"
        ((compteur_purge_taille++)) || true
    else
        log_message "ERROR" "Impossible de supprimer '$archive_lourde'."
    fi
done < <(find "$DOSSIER_LOGS" -maxdepth 1 -type f -name "*.log.*.gz" -size +"$TAILLE_MAX" -print0 2>/dev/null || true)

log_message "INFO" "Terminé. Rotations : $compteur_rotation | Purges âge : $compteur_purge_age | Purges taille : $compteur_purge_taille."
exit 0
