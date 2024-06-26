#!/bin/bash

# echo "###########################################"
# echo "Arguments : $*"
# echo "N° of args : $#"
# echo "###########################################"
# echo ""
usage()
{
cat <<EOF
Usage:
    ./script_poubelle.sh <FICHIER_1> <FICHIER_2> ... <FICHIER_10>

Description :
    Le script "script_poubelle.sh" vous permet de simuler l'equivalent d'une poubelle sur un systeme Linux.
    Le script fonctionne sur les fichiers ordinaires et repertoires dont l'utilisateur à l'autorisatrion de supprimer. Le reste sera exclu de toute operation.
EOF
exit 1
}

create_file()
{
    #Creer les fichiers
    for i in {1..10}
    do
        touch file${i}
    done
}

check_files()
{
    files=$@
    echo "files : ${files}"

    #Iteration sur chaque fichiers de la liste
    for file in ${files}
    do
        #Verifier que le fichier existe et que l'utilisateur a les droits d'ecriture
        if [ -w ${file} ]
        then
            files_to_delete="${files_to_delete} ${file}"
        else
            echo "Le fichier ${file} n'existe pas ou vous n'avez pas les droits suffisant pour le supprimer"
        fi
    done

    # Si aucun des fichier passé en paramètre existe
    if [ -z "${files_to_delete}" ]
    then
        echo "Aucun fichier passé en paramètre n'est reconnu."
        echo "Avez vous spécifié les bons chemins ?"
        exit 1
    fi

    echo "file to delete : ${files_to_delete}"
}

create_archive()
{
    if [ -n "${files_to_delete}" ]
    then
        #Repertoire trash de l'utilisateur courant
        archive_dir=~/trash
        mkdir -p $archive_dir
	archive_name=archive_$(date +%d_%m_%Y_%k_%M)_tar.gz
        tar -czvf ${archive_dir}/${archive_name} ${files_to_delete}
        echo "Archive : ${archive_name} cree"
        echo "#######################################"
        echo "Contenu de l'archive :"
        tar -tzvf ${archive_dir}/${archive_name}
        echo "#######################################"
        echo
    fi
}

ask_for_deletion()
{
    while true; do
                read -p "Voulez vous supprimer les fichiers originaux ? [o/n] " on
                case ${on} in
                    [Oo]* ) delete_files; break;;
                    [Nn]* ) break;;
                    * ) echo "Veuillez repondre par oui[o] ou non[n]";;
                esac
    done
}

delete_files()
{
    echo "Suppression de ${files_to_delete} ..."
    rm -rf ${files_to_delete}
}

check_args()
{
    #Verifier le nombre d'arguments
    if [ $# -gt 10 ] || [ $# -lt 1 ]
    then
        echo "[ERREUR] : Le script doit recevoir entre 1 et 10 fichiers en parametres. Vous en avez specifie : $#"
        echo
        usage
        exit 1
    fi

}

main()
{
    check_args "$@"
    create_file
    check_files "$@"
    create_archive
    ask_for_deletion
}

main "$@"
