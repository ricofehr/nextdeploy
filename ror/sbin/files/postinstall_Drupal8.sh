#!/bin/bash

URI="$1"
URIADMIN="admin.${URI}"
URIMOBILE="m.${URI}"
DOCROOT="$(pwd)/server"

pushd $DOCROOT >/dev/null
/usr/local/bin/drush cim >/dev/null 2>&1
popd >/dev/null