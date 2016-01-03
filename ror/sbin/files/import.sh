#!/bin/bash

ISMYSQL=0
ISMONGO=0
URI=''
URIADMIN=''
URIMOBILE=''
FRAMEWORK=''
FTPUSER=''
FTPPASSWD=''
FTPHOST='nextdeploy'
DOCROOT="$(pwd)/server"

# display helpn all of this parametes are setted during vm install
posthelp() {
  cat <<EOF
Usage: $0 [options]

-h                this is some help text.
--framework xxxx  framework of the project. choices between symfony2, drupal, wordpress, static (default)
--ftpuser xxxx    ftp user on nextdeploy ftp server
--ftppasswd xxxx  ftp password on nextdeploy ftp server
--ftphost xxxx    override nextdeploy ftp host
--ismysql x       1/0 if mysql-server present (default is 0)
--ismongo x       1/0 if mysql-server present (default is 0)
--uri xxxx        set main uri for the website
EOF

exit 0
}


# Parse cmd options
while (($# > 0)); do
  case "$1" in
    --framework)
      shift
      FRAMEWORK="$1"
      shift
      ;;
    --ftpuser)
      shift
      FTPUSER="$1"
      shift
      ;;
    --ftppasswd)
      shift
      FTPPASSWD="$1"
      shift
      ;;
    --ftphost)
      shift
      FTPHOST="$1"
      shift
      ;;
    --ismysql)
      shift
      ISMYSQL="$1"
      shift
      ;;
    --ismongo)
      shift
      ISMONGO="$1"
      shift
      ;;
    --uri)
      shift
      URI="$1"
      shift
      ;;
    -h)
      shift
      posthelp
      ;;
    *)
      shift
      ;;
  esac
done

# drupal actions
postdrupal() {
  # decompress assets archive
  assetsarchive "${DOCROOT}/sites/default/files"
  (( $? != 0 )) && echo "No assets archive or corrupt file"

  # import data
  importdatas

  # if sql or mongo import, updb and cc
  pushd ${DOCROOT} > /dev/null
  drush updb -y
  drush -y cc all
  (( $? -= 0 )) && drush -y cr
  popd > /dev/null
}

# symfony actions
postsymfony2() {
  # decompress assets archive
  assetsarchive "${DOCROOT}/web/uploads"
  (( $? != 0 )) && echo "No assets archive or corrupt file"

  # import data
  importdatas

  # if sql or mongo import, updb and cc
  pushd ${DOCROOT} > /dev/null
  php app/console doctrine:schema:update --force
  php app/console cache:clear --env=prod
  php app/console cache:clear --env=dev
  popd > /dev/null
}

# wordpress actions
postwordpress() {
  # decompress assets archive
  assetsarchive "${DOCROOT}/wp-content/uploads"
  (( $? != 0 )) && echo "No assets archive or corrupt file"

  # import data
  importdatas

  # if sql or mongo import, updb and cc
  pushd ${DOCROOT} > /dev/null
  wp option update siteurl "http://${URI}"
  popd > /dev/null
}

# static actions
poststatic() {
  importdatas
}

# import sql or mongo dump
importdatas() {
  # sql part
  if (( ISMYSQL == 1 )); then
    importsql
    if (( $? != 0 )); then
      echo "No sql file or corrupt file"
      (( ISMONGO == 0 )) && exit 0
    fi
  fi

  # mongo part
  if (( ISMONGO == 1 )); then
    importmongo
    if (( $? != 0 )); then
      echo "No mongo file or corrupt file"
      exit 0
    fi
  fi
}

# import a sql dump into mysql server
importsql() {
  local ret=0
  local sqlfile=''

  # prepare tmp folder
  rm -rf /tmp/dump
  mkdir /tmp/dump

  pushd /tmp/dump > /dev/null
  ncftpget -u $FTPUSER -p $FTPPASSWD $FTPHOST . dump/*.sql.gz
  if (( $? == 0 )); then
    # take the first one
    sqlfile="$(ls *.gz | head -n 1 | tr -d "\n")"
    zcat "$sqlfile" | mysql -u s_bdd -ps_bdd s_bdd
    (( $? != 0 )) && ret=1
  else
    ret=1
  fi
  popd > /dev/null
  rm -rf /tmp/dump
  return $ret
}

# import a mongo dump into mongoserver
importmongo() {
  local ret=0
  local mongofile=''
  local mongofolder=''

  # prepare tmp folder
  rm -rf /tmp/dump
  mkdir /tmp/dump

  pushd /tmp/dump > /dev/null
  ncftpget -u $FTPUSER -p $FTPPASSWD $FTPHOST . dump/*.tar.gz
  if (( $? == 0 )); then
    # take the first one
    mongofile="$(ls *.tar.gz | head -n 1 | sed "s;.tar.gz;;" | tr -d "\n")"
    tar xvfz ${mongofile}.tar.gz
    rm -f *.tar.gz
    mongofolder="$(ls)"
    LC_ALL=en_US.UTF-8 mongorestore -d $mongofolder --drop $mongofolder
    (( $? != 0 )) && ret=1
  else
    ret=1
  fi
  popd > /dev/null
  rm -rf /tmp/dump
  return $ret
}

# update website asset folder from archive file
assetsarchive() {
  local ret=0
  local archivefile=''
  local destfolder="$1"

  # prepare tmp folder
  rm -rf /tmp/assets
  mkdir /tmp/assets

  pushd /tmp/assets > /dev/null
  ncftpget -u $FTPUSER -p $FTPPASSWD $FTPHOST . assets/*.tar.gz
  if (( $? == 0 )); then
    # take the first one
    archivefile="$(ls *.tar.gz | head -n 1 | tr -d "\n")"
    tar xvfz "$archivefile"
    rm -f "$archivefile"
    if (( $? == 0 )); then
      mkdir -p ${destfolder}
      rsync -av * ${destfolder}/
    else
      ret=1
    fi
    rm -f *.tar.gz
  else
    ret=1
  fi
  popd > /dev/null
  rm -rf /tmp/assets
  return $ret
}

case "$FRAMEWORK" in
  "drupal"*)
    postdrupal
    ;;
  "symfony"*)
    postsymfony2
    ;;
  "wordpress")
    postwordpress
    ;;
  *)
    poststatic
    ;;
esac
