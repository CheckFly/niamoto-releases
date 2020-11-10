#!/bin/bash

PORT=9022

error(){ 
    echo "ERREUR : parametres invalides !" >&2 
    echo "utilisez l'option -h pour en savoir plus" >&2 
} 

usage(){ 
    echo "Usage: ./update.sh [OPTIONS]

    Script utiliser pour mettre à jour les données de Niamoto Portal
    - Récupération des données et recréation des views
    - Intégration dans la base Niamoto Portal
    - Export django
    - Push sur Git
    - Mise à jour du site sur le serveur applicatif

    -h, --help        afficher l'aide 
    -f, --full        réinstallation complète y/n
    -p, --password    mot de passe sql
    -P, --push        push git y/n
    -s, --sshpassword mot de passe ssh
    -v, --version     Affiche la version"
}

version(){
    echo "update Niamoto Portal version: 0.0.2"
}

traitement(){
    echo "*************************************************************************************"
    echo "************************** Update Data Niamoto portal *******************************"
    echo "*************************************************************************************"
    echo ""
    echo "************************* Installation function SQL *********************************"
    psql -d amapiac -h niamoto.ird.nc -U amapiac \
    -f "${NIAMOTO_RELEASES}/niamoto_preprocess/function_create_table.sql" \
    -f "${NIAMOTO_RELEASES}/niamoto_preprocess/function_drop_table.sql" \
    -f "${NIAMOTO_RELEASES}/niamoto_preprocess/function_insert_data.sql" \
    -f "${NIAMOTO_RELEASES}/niamoto_portal/function_insert_data.sql" \
    -f "${NIAMOTO_RELEASES}/niamoto_portal/function_insert_shape.sql" \
    -f "${NIAMOTO_RELEASES}/niamoto_portal/function_insert_shape_frequency_cover.sql" \
    -f "${NIAMOTO_RELEASES}/niamoto_portal/function_insert_shape_frequency_elevation.sql" \
    -f "${NIAMOTO_RELEASES}/niamoto_portal/function_insert_shape_frequency_fragmentation.sql" \
    -f "${NIAMOTO_RELEASES}/niamoto_portal/function_insert_shape_frequency_holdridge.sql"\
    -f "${NIAMOTO_RELEASES}/niamoto_portal/function_insert_taxon.sql"\
    -f "${NIAMOTO_RELEASES}/niamoto_portal/function_insert_taxon_frequency.sql"\
    -f "${NIAMOTO_RELEASES}/niamoto_portal/function_insert_taxon_frequency_stat.sql"\
    -f "${NIAMOTO_RELEASES}/niamoto_portal/function_insert_taxon_phenology.sql"

    # if  [ $FULL = 'y' ]; then
    #     echo "************************* preLoad data *************************************************"
    #     psql -d amapiac -h niamoto.ird.nc -U amapiac -w -c "SELECT niamoto_preprocess.install();"
    # else
    #     echo "************************* No preLoad data ******************************************" 
    # fi
    echo "************************* Load data *************************************************"
    psql -d amapiac -h niamoto.ird.nc -U amapiac -w -c "SELECT niamoto_portal.insert_data();"
    if [ $PUSH = 'y' ];
    then
        echo "************************* Push data *************************************************"
        # connect virtualenv
        sudo docker exec niamoto-django-local_niamoto-django_1 bash generate_data.sh
        sudo mv ~/data/data.json ~/
        sshpass -p $SSHPASSWORD scp -P $PORT ~/data.json niamoto.nc:/home/niamoto-portal
        sshpass -p $SSHPASSWORD ssh -p $PORT niamoto.nc sudo mv /home/niamoto-portal/data.json /home/niamoto-portal/data
        sshpass -p $SSHPASSWORD ssh -p $PORT niamoto.nc "export NIAMOTO_COMPOSE=/home/niamoto-portal/niamoto-docker-compose/; . /home/niamoto-portal/niamoto-docker-compose/update.sh"
    fi 
}


# Pas de paramètre 
[[ $# -lt 1 ]] && error 

# -o : options courtes 
# -l : options longues 
options=$(getopt -o hfpPsv: --long help,password,push,sshpassword,version: -n 'Update Niamoto Portal' -- "$@") 

# éclatement de $options en $1, $2... 
eval set -- $options
exit=0
while true; do
    case "$1" in 
        # -f|--full)
        #     FULL="$6";
        #     shift;;
        -p|--password)
            export PGPASSWORD="$5";
            shift;;
        -P|--push)
            PUSH="$5";
            shift;;
        -s|--sshpassword)
            SSHPASSWORD="$5";
            shift;;
        -h|--help)
            usage;
            exit=1;
            break;;
        -v|--version) 
            version;
            exit=1;
            break;;
        --) # fin des options 
            shift 
            break;; 
        *) error 
            shift
            exit 1;;
    esac 
done

if [ $exit -eq 0 ]
then
    traitement
fi
