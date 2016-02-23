#!/bin/bash
#backup_mysqldump.sh
#Script Para Generar Backups Dinamicos --EJECUTAR COMO ROOT
#Requerimientos
# *) que el servidor remoto tenga relacion de confianza con el servidor local (ssh-copy-id -i)
#Variable de fecha con la que se guardaran los archivos
fecha=$(date +"%F-%H-%M-%S-%N")

#Varibles de rutas
MYSQL_HOME=/opt/mysql/
MYSQL_PRODUCT=/opt/mysql/DATABASE
MYSQL_CONFIGURATION_FILE_PATH="$MYSQL_PRODUCT/mysql/my.cnf"
DATABASE_NAME=mydatabase
BACKUP_DIRECTORY="/opt/mysql/backup/$DATABASE_NAME/mysqldump"
REMOTE_HOST='192.168.0.1'
REMOTE_PATH="/opt/mysql/remotes_backup/192.168.0.2/$DATABASE_NAME/mysqldump"

mkdir -p $BACKUP_DIRECTORY/$fecha
cd $BACKUP_DIRECTORY
cd $fecha

function backup {
  #Backup base de datos
  CMD="$MYSQL_PRODUCT/mysql/bin/mysqldump -v -u root -pKupMynucBev1 -S $MYSQL_PRODUCT/data/mysqld.sock --databases $DATABASE_NAME --single-transaction -R > ./backup-$DATABASE_NAME-$fecha.sql 2> backup-$DATABASE_NAME-$fecha.log"
  eval $CMD

  #Backup  my.cnf local copy
  echo "Backup Configuration File">>backup-$DATABASE_NAME-$fecha.log
  cp $MYSQL_CONFIGURATION_FILE_PATH ./my.cnf >>backup-$DATABASE_NAME-$fecha.log 2>>backup-$DATABASE_NAME-$fecha.log
  echo "Compress File">>backup-$DATABASE_NAME-$fecha.log
  CMD="tar -zcvf backup-$DATABASE_NAME-$fecha.tar.gz ./backup-$DATABASE_NAME-$fecha.sql ./my.cnf >> backup-$DATABASE_NAME-$fecha.log 2>> backup-$DATABASE_NAME-$fecha.log"
  eval $CMD
  rm ./backup-$DATABASE_NAME-$fecha.sql
  rm ./my.cnf
}
#backup Local
backup

#Backup database and my.cnf remote copy
mkdir remote
cd remote
backup

#Copiado Remoto
echo "Copiado Remoto" >> ../backup-$DATABASE_NAME-$fecha.log
CMD="ssh root@$REMOTE_HOST 'mkdir -p $REMOTE_PATH/$fecha'"
eval $CMD
scp ./* root@$REMOTE_HOST:/$REMOTE_PATH/$fecha >> ../backup-$DATABASE_NAME-$fecha.log 2>> ../backup-$DATABASE_NAME-$fecha.log
cd ..
rm -r remote
