#!/bin/bash
set -e

echo "=== Osiris CI - Démarrage ==="

# ── Port Railway (défaut 80 si non défini) ──────────────────────────────────
APP_PORT="${PORT:-80}"
echo "Port d'écoute : ${APP_PORT}"

# Patcher ports.conf
if [ -f /etc/apache2/ports.conf ]; then
    sed -i "s/^Listen [0-9]*/Listen ${APP_PORT}/" /etc/apache2/ports.conf
    echo "ports.conf patché ✓"
fi

# ── DocumentRoot → /public (requis GLPI 10+) ────────────────────────────────
# Remplace DocumentRoot et Directory pour pointer vers /public
for conf in /etc/apache2/sites-enabled/*.conf /etc/apache2/sites-enabled/*; do
    [ -f "$conf" ] || continue
    # Port
    sed -i "s/<VirtualHost \*:80>/<VirtualHost *:${APP_PORT}>/" "$conf"
    # DocumentRoot
    sed -i "s|DocumentRoot /var/www/html/glpi$|DocumentRoot /var/www/html/glpi/public|g" "$conf"
    sed -i "s|DocumentRoot /var/www/html/glpi/\b|DocumentRoot /var/www/html/glpi/public|g" "$conf"
    # Directory block
    sed -i "s|<Directory /var/www/html/glpi>|<Directory /var/www/html/glpi/public>|g" "$conf"
    sed -i "s|<Directory /var/www/html/glpi/>|<Directory /var/www/html/glpi/public/>|g" "$conf"
done

# Si aucun vhost n'existe ou DocumentRoot pas patché, écrire un vhost complet
VHOST_FILE="/etc/apache2/sites-enabled/glpi.conf"
if [ ! -f "$VHOST_FILE" ] || ! grep -q "/glpi/public" "$VHOST_FILE" 2>/dev/null; then
    cat > "$VHOST_FILE" << VHOST
<VirtualHost *:${APP_PORT}>
    DocumentRoot /var/www/html/glpi/public

    <Directory /var/www/html/glpi/public>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted

        RewriteEngine On
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteRule ^(.*)$ index.php [QSA,L]
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/glpi_error.log
    CustomLog \${APACHE_LOG_DIR}/glpi_access.log combined
    LogLevel error
</VirtualHost>
VHOST
    echo "VirtualHost /public écrit ✓"
fi

# Activer mod_rewrite
a2enmod rewrite 2>/dev/null || true

# Désactiver la page par défaut Apache
a2dissite 000-default 2>/dev/null || true
a2ensite glpi 2>/dev/null || true

# Supprimer l'avertissement ServerName
grep -q "^ServerName" /etc/apache2/apache2.conf 2>/dev/null || echo "ServerName localhost" >> /etc/apache2/apache2.conf

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
    cp /osiris/osiris_logo.png "$LOGO_DIR/osiris_logo.png" 2>/dev/null && echo "Logo Osiris copié ✓" || echo "Logo skip"
    cp /osiris/osiris_logo_full.webp "$LOGO_DIR/osiris_logo_full.webp" 2>/dev/null || true
fi

if [ -f "$PHP_CFG" ]; then
    cp /osiris/CFG_GLPI.php "$PHP_CFG" 2>/dev/null && echo "App name Osiris CI ✓" || true
fi

echo "=== Lancement Apache sur port ${APP_PORT} ==="
exec /opt/glpi-start.sh
