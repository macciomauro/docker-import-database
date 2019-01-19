#!/bin/bash

cd ./

echo "-----------------------------------------------------";
echo "--- Welcome to the Docker Database Restore System ---";
echo "-----------------------------------------------------";

echo "Tell me .env name and press [ENTER]:";
read ENV_NAME
if [ "${ENV_NAME}" == "" ]
then
    echo "Empty .env name given";
    exit 1;
fi

if [ ! -f "${ENV_NAME}.env" ]; then
    echo "-----------------------------------------------------";
    echo "[ERROR] ${ENV_NAME}.env file not found";
    echo "-----------------------------------------------------";
    exit 1;
fi

export $(egrep -v '^#' ${ENV_NAME}.env | xargs)


if [ -z "${DUMP_DIR}" ] || [ -z "${MYSQL_USER}" ] || [ -z "${MYSQL_PASSWORD}" ] || [ -z "${DATABASE_CONTAINER_NAME}" ] || [ -z "${MYSQL_DATABASE_NAME}" ]
then
    echo "-----------------------------------------------------";
    echo "[ERROR] Some .env values is missing or wrong";
    echo "-----------------------------------------------------";
    exit 1;
fi

echo "-----------------------------------------------------";
echo "Using ${ENV_NAME}.env";
echo "-----------------------------------------------------";

echo "Choose a gzipped file (*.sql.gz) to dump";
echo "ATTENTION! All previous data will be lost!";
echo "-----------------------------------------------------";
select FILENAME in "${DUMP_DIR}"/*.sql.gz;
do
    if [[ $FILENAME = "" ]]; then
        echo "-----------------------------------------------------";
        echo "[ERROR] Empty Choise";
        echo "-----------------------------------------------------";
        break;
        exit -1;
    else
        CHOSEN_DUMP=$(basename "$FILENAME");
        echo "-----------------------------------------------------";
        echo "You picked ${CHOSEN_DUMP}";
        echo "-----------------------------------------------------";
        echo "Start importing...";
        docker cp ${DUMP_DIR}/${CHOSEN_DUMP} ${DATABASE_CONTAINER_NAME}:/db_dump.sql.gz
        echo "-----------------------------------------------------";
        echo "Import completed";
        echo "-----------------------------------------------------";
        echo "Start dumping to ${MYSQL_DATABASE_NAME}...";
        docker exec ${DATABASE_CONTAINER_NAME} bash -c "mysql -u ${MYSQL_USER} -p${MYSQL_PASSWORD} --default-character-set=utf8 -e 'DROP DATABASE IF EXISTS ${MYSQL_DATABASE_NAME}; CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE_NAME} DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;'"
        docker exec ${DATABASE_CONTAINER_NAME} bash -c "zcat /db_dump.sql.gz | mysql -u ${MYSQL_USER} -p${MYSQL_PASSWORD} --default-character-set=utf8 ${MYSQL_DATABASE_NAME}"
        echo "-----------------------------------------------------";
        echo "Dump completed";
        echo "-----------------------------------------------------";
        echo "Removing import file...";
        docker exec ${DATABASE_CONTAINER_NAME} bash -c "rm /db_dump.sql.gz"
        echo "-----------------------------------------------------";
        echo "File removed";
        echo "-----------------------------------------------------";
        echo "Bye!";
        echo "-----------------------------------------------------";
        break;
    fi
done
exit;