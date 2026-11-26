#!/usr/bin/env python3
# Nom : backup.py
# Description : Sauvegarde compressée et horodatée d'un dossier avec gestion d'erreurs, logs et notification par e-mail simulée

import logging
import os
import shutil
import sys
from datetime import datetime

# --- Configuration globale ---
EMAIL_ADMIN = ["fakri@epf.fr","nikola@epf.fr"]
FICHIER_LOG = "backup.log"

# Configuration du système de logs (fichier + console)
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
    handlers=[
        logging.FileHandler(FICHIER_LOG, encoding="utf-8"),
        logging.StreamHandler(sys.stdout),
    ],
)


def envoyer_email(sujet: str, message: str) -> None:
    """Simule l'envoi d'un e-mail de notification à l'administrateur."""
    destinataires = ", ".join(EMALS\ADMIN)
    logging.info(f"Envoi de la notification par e-mail à {EMAIL_ADMIN}...")
    print("\n--- E-MAIL SIMULÉ ---")
    print(f"À      : {EMAIL_ADMIN}")
    print(f"Sujet  : {sujet}")
    print(f"Message:\n{message}")
    print("---------------------\n")


def sauvegarder(source: str, destination: str) -> bool:
    """Vérifie le dossier source, crée une archive .tar.gz horodatée et notifie le résultat."""
    source_propre = os.path.normpath(source)
    nom_dossier = os.path.basename(source_propre)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    chemin_archive = os.path.join(destination, f"backup_{nom_dossier}_{timestamp}")

    logging.info(f"Démarrage de la sauvegarde de '{source_propre}' vers '{destination}'.")

    try:
        # Vérification de l'existence et du type du dossier source
        if not os.path.exists(source_propre):
            raise FileNotFoundError(f"Le chemin source '{source_propre}' n'existe pas.")
        if not os.path.isdir(source_propre):
            raise NotADirectoryError(f"Le chemin '{source_propre}' n'est pas un dossier.")

        # Création du dossier de destination si inexistant
        os.makedirs(destination, exist_ok=True)

        # Création de l'archive compressée (.tar.gz)
        fichier_cree = shutil.make_archive(chemin_archive, "gztar", source_propre)
        logging.info(f"Sauvegarde réussie. Archive générée : {fichier_cree}")

        envoyer_email(
            sujet=f"[SUCCÈS] Sauvegarde de {nom_dossier}",
            message=f"La sauvegarde de '{source_propre}' s'est terminée avec succès.\nArchive : {fichier_cree}",
        )
        return True

    except (FileNotFoundError, NotADirectoryError, PermissionError, OSError) as erreur:
        # Gestion des erreurs système (chemin invalide, permissions, disque plein)
        logging.error(f"Échec de la sauvegarde de '{source_propre}' : {erreur}")
        envoyer_email(
            sujet=f"[ERREUR] Échec sauvegarde de {nom_dossier}",
            message=f"Une erreur est survenue lors de la sauvegarde de '{source_propre}' :\n{erreur}",
        )
        return False


def main() -> None:
    """Valide les arguments en ligne de commande et lance la sauvegarde."""
    if len(sys.argv) != 3:
        logging.warning("Nombre d'arguments invalide.")
        print("Usage : ./backup.py <dossier_source> <dossier_destination>")
        sys.exit(1)

    succes = sauvegarder(sys.argv[1], sys.argv[2])
    sys.exit(0 if succes else 1)


if __name__ == "__main__":
    main()
