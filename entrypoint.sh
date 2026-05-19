#!/bin/bash
set -e

echo "=== Osiris CI - Démarrage ==="

# ── Port Railway (défaut 80 si non défini) ──────────────────────────────────
APP_PORT="${PORT:-80}"
echo "Port d'écoute : ${APP_PORT}"

# Patcher ports.conf : remplace toute ligne "Listen <n>" par le bon port
if [ -f /etc/apache2/ports.conf ]; then
    sed -i "s/^Listen [0-9]*/Listen ${APP_PORT}/" /etc/apache2/ports.conf
    echo "ports.conf patché ✓"
fi

# Patcher les VirtualHost *:80 → *:$APP_PORT dans tous les sites activés
for conf in /etc/apache2/sites-enabled/*.conf /etc/apache2/sites-enabled/*; do
    [ -f "$conf" ] || continue
    sed -i "s/<VirtualHost \*:80>/<VirtualHost *:${APP_PORT}>/" "$conf"
done
echo "VirtualHost patché ✓"

# Supprimer l'avertissement ServerName
if ! grep -q "^ServerName" /etc/apache2/apache2.conf 2>/dev/null; then
    echo "ServerName localhost" >> /etc/apache2/apache2.conf
fi

# ── Config base de données depuis variables Railway MySQL ───────────────────
mkdir -p /var/www/html/glpi/config

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

# ── Branding Osiris CI ───────────────────────────────────────────────────────
LOGO_DIR="/var/www/html/glpi/public/pics/logos"
PHP_CFG="/var/www/html/glpi/src/autoload/CFG_GLPI.php"

if [ -d "$LOGO_DIR" ]; then
    cp /osiris/osiris_logo.png "$LOGO_DIR/osiris_logo.png" 2>/dev/null && echo "Logo Osiris copié ✓" || echo "Logo skip (répertoire non prêt)"
    cp /osiris/osiris_logo_full.webp "$LOGO_DIR/osiris_logo_full.webp" 2>/dev/null || true
fi

if [ -f "$PHP_CFG" ]; then
    cp /osiris/CFG_GLPI.php "$PHP_CFG" 2>/dev/null && echo "App name Osiris CI ✓" || true
fi

echo "=== Lancement Apache sur port ${APP_PORT} ==="
exec /opt/glpi-start.sh
