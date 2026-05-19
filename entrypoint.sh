#!/bin/bash
set -e

echo "=== Osiris CI - Démarrage ==="

# ── Port Railway ─────────────────────────────────────────────────────────────
APP_PORT="${PORT:-80}"
echo "Port : ${APP_PORT}"

# Patch uniquement notre vhost connu (figé au build)
sed -i "s/<VirtualHost \*:80>/<VirtualHost *:${APP_PORT}>/" /etc/apache2/sites-available/glpi.conf
sed -i "s/^Listen [0-9]*/Listen ${APP_PORT}/" /etc/apache2/ports.conf
grep -q "^ServerName" /etc/apache2/apache2.conf || echo "ServerName localhost" >> /etc/apache2/apache2.conf

echo "Apache → port ${APP_PORT}, DocumentRoot /var/www/html/glpi/public ✓"

# ── Config base de données ────────────────────────────────────────────────────
mkdir -p /var/www/html/glpi/config

DB_HOST="${MYSQLHOST:-${MYSQL_HOST:-localhost}}"
DB_PORT="${MYSQLPORT:-${MYSQL_PORT:-3306}}"
DB_USER="${MYSQLUSER:-${MYSQL_USER:-root}}"
DB_PASS="${MYSQLPASSWORD:-${MYSQL_PASSWORD:-}}"
DB_NAME="${MYSQLDATABASE:-${MYSQL_DATABASE:-railway}}"

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

echo "config_db.php → ${DB_HOST}:${DB_PORT}/${DB_NAME} ✓"

# ── Branding Osiris CI ────────────────────────────────────────────────────────
LOGO_DIR="/var/www/html/glpi/public/pics/logos"
PHP_CFG="/var/www/html/glpi/src/autoload/CFG_GLPI.php"

[ -d "$LOGO_DIR" ] && cp /osiris/osiris_logo.png "$LOGO_DIR/" 2>/dev/null && echo "Logo ✓" || true
[ -d "$LOGO_DIR" ] && cp /osiris/osiris_logo_full.webp "$LOGO_DIR/" 2>/dev/null || true
[ -f "$PHP_CFG" ]  && cp /osiris/CFG_GLPI.php "$PHP_CFG" 2>/dev/null && echo "App name Osiris CI ✓" || true

echo "=== Lancement Apache ==="
exec /opt/glpi-start.sh
