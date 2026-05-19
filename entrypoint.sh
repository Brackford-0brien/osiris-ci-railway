#!/bin/bash
set -e

echo "=== Osiris CI - Démarrage ==="

# Écrire config_db.php depuis les variables Railway MySQL
mkdir -p /var/www/html/glpi/config

# Railway fournit ces variables pour le plugin MySQL
DB_HOST="${MYSQLHOST:-${MYSQL_HOST:-glpi-db}}"
DB_PORT="${MYSQLPORT:-${MYSQL_PORT:-3306}}"
DB_USER="${MYSQLUSER:-${MYSQL_USER:-glpi}}"
DB_PASS="${MYSQLPASSWORD:-${MYSQL_PASSWORD:-glpi_pass}}"
DB_NAME="${MYSQLDATABASE:-${MYSQL_DATABASE:-glpi}}"

cat > /var/www/html/glpi/config/config_db.php << EOF
<?php
class DB extends DBmysql {
   public \$dbhost = '${DB_HOST}';
   public \$dbuser = '${DB_USER}';
   public \$dbpassword = '${DB_PASS}';
   public \$dbdefault = '${DB_NAME}';
   public \$use_timezones = true;
   public \$use_utf8mb4 = true;
   public \$allow_datetime = false;
   public \$allow_signed_keys = false;
}
EOF

echo "config_db.php écrit → ${DB_HOST}:${DB_PORT}/${DB_NAME}"

# Appliquer les fichiers Osiris CI (à chaque démarrage)
# pour s'assurer qu'ils sont toujours présents même après une réinitialisation
LOGO_DIR="/var/www/html/glpi/public/pics/logos"
PHP_CFG="/var/www/html/glpi/src/autoload/CFG_GLPI.php"

if [ -d "$LOGO_DIR" ]; then
    cp /osiris/osiris_logo.png "$LOGO_DIR/osiris_logo.png" 2>/dev/null && echo "Logo Osiris copié ✓" || echo "Logo skip (répertoire non prêt)"
    cp /osiris/osiris_logo_full.webp "$LOGO_DIR/osiris_logo_full.webp" 2>/dev/null || true
fi

if [ -f "$PHP_CFG" ]; then
    cp /osiris/CFG_GLPI.php "$PHP_CFG" 2>/dev/null && echo "App name Osiris CI ✓" || true
fi

echo "=== Lancement Apache ==="
exec /opt/glpi-start.sh
