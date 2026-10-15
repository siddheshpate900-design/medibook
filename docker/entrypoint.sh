#!/bin/sh
# =====================================================================
#  MediBook container start.
#
#  The web application reads its database settings from
#      webapps/ROOT/WEB-INF/classes/db.properties
#  which is built into the image with the local development defaults
#  (root, no password, localhost). On a hosted server that file has to
#  carry the real address, user and password, and those arrive here as the
#  environment variables DB_URL, DB_USER and DB_PASSWORD.
#
#  The file is written rather than edited with sed, because a JDBC URL is
#  full of ? and & characters that sed would have to be told about.
#
#  Nothing here changes when the code changes. If you add a setting, add it
#  to this file and to src/main/resources/db.properties with the same key.
# =====================================================================
set -eu

TOMCAT="${CATALINA_HOME:-/usr/local/tomcat}"
# a normal Tomcat install keeps the applications and the configuration in
# CATALINA_BASE, which is the same folder as CATALINA_HOME in the container
BASE="${CATALINA_BASE:-$TOMCAT}"
PROPS="$BASE/webapps/ROOT/WEB-INF/classes/db.properties"

if [ -z "${DB_URL:-}" ]; then
  echo "MediBook: DB_URL is not set, so the container does not know which database to use." >&2
  echo "MediBook: in the Render dashboard, add DB_URL, DB_USER and DB_PASSWORD under" >&2
  echo "MediBook: Environment, copied from your TiDB Cloud cluster (Connect -> connect with MySQL client)." >&2
  exit 1
fi

if [ ! -d "$(dirname "$PROPS")" ]; then
  echo "MediBook: $PROPS is missing. The image was built without the web application." >&2
  exit 1
fi

umask 077
cat > "$PROPS" <<EOF
# written at container start by docker/entrypoint.sh, do not commit values here
db.driver=com.mysql.cj.jdbc.Driver
db.url=${DB_URL}
db.username=${DB_USER:-root}
db.password=${DB_PASSWORD:-}
EOF

# Render can be told to send traffic to a port other than 8080. Tomcat's own
# default is 8080, so this only runs when PORT says otherwise.
PORT="${PORT:-8080}"
if [ "$PORT" != "8080" ]; then
  if [ -f "$BASE/conf/server.xml" ]; then
    sed -i "s|Connector port=\"8080\" |Connector port=\"$PORT\" |" "$BASE/conf/server.xml"
    echo "MediBook: Tomcat moved to port $PORT"
  else
    echo "MediBook: PORT is $PORT but $BASE/conf/server.xml was not found, staying on 8080" >&2
  fi
fi

echo "MediBook: starting Tomcat for database user ${DB_USER:-root}"
# the official Tomcat image puts catalina.sh on the PATH, a local Tomcat does
# not, so try the one inside CATALINA_HOME first and `./scripts/docker-test.sh`
# works the same way as the container
if [ -x "$TOMCAT/bin/catalina.sh" ]; then
  exec "$TOMCAT/bin/catalina.sh" run
fi
exec catalina.sh run
