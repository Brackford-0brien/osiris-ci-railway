#!/bin/bash
set -e

echo "=== Osiris CI - Démarrage ==="

APP_PORT="${PORT:-80}"
GLPI_DIR=/var/www/html/glpi

# ── 1. PHP : timezone + cookie httponly ─────────────────────────────────────
PHP_DIR=$(ls -d /etc/php/*/apache2 2>/dev/null | head -1)
if [ -n "$PHP_DIR" ]; then
    echo 'date.timezone = "Africa/Abidjan"' > "${PHP_DIR}/conf.d/timezone.ini"
    sed -i 's,session.cookie_httponly = *\(on\|off\|true\|false\|0\|1\)\?,session.cookie_httponly = on,gi' "${PHP_DIR}/php.ini" 2>/dev/null || true
fi

# ── 2. config_db.php depuis variables Railway MySQL ─────────────────────────
mkdir -p "${GLPI_DIR}/config"
DB_HOST="${MYSQLHOST:-localhost}"
DB_USER="${MYSQLUSER:-root}"
DB_PASS="${MYSQLPASSWORD:-}"
DB_NAME="${MYSQLDATABASE:-railway}"

cat > "${GLPI_DIR}/config/config_db.php" << EOF
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
echo "config_db.php → ${DB_HOST}/${DB_NAME} ✓"

# ── 3. Clés crypto (identiques au dump SQL → validation tokens OK) ──────────
cp /osiris/glpicrypt.key "${GLPI_DIR}/config/glpicrypt.key"
cp /osiris/oauth.pem     "${GLPI_DIR}/config/oauth.pem"
cp /osiris/oauth.pub     "${GLPI_DIR}/config/oauth.pub"
chmod 640 "${GLPI_DIR}/config/glpicrypt.key" "${GLPI_DIR}/config/oauth.pem" "${GLPI_DIR}/config/oauth.pub"
echo "Clés crypto copiées ✓"

# ── 4. Branding ─────────────────────────────────────────────────────────────
cp /osiris/osiris_logo.png       "${GLPI_DIR}/public/pics/logos/" 2>/dev/null && echo "Logo ✓" || true
cp /osiris/osiris_logo_full.webp "${GLPI_DIR}/public/pics/logos/" 2>/dev/null || true
cp /osiris/CFG_GLPI.php          "${GLPI_DIR}/src/autoload/CFG_GLPI.php" 2>/dev/null && echo "App name Osiris CI ✓" || true
chown -R www-data:www-data "${GLPI_DIR}"

# ── 4. Apache : vhost /public sur le port Railway ───────────────────────────
cat > /etc/apache2/sites-available/000-default.conf << EOF
<VirtualHost *:${APP_PORT}>
    DocumentRoot ${GLPI_DIR}/public

    <Directory ${GLPI_DIR}/public>
        Require all granted
        RewriteEngine On
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteRule ^(.*)\$ index.php [QSA,L]
    </Directory>

    ErrorLog /var/log/apache2/error-glpi.log
    CustomLog /var/log/apache2/access-glpi.log combined
    LogLevel error
</VirtualHost>
EOF

echo "Listen ${APP_PORT}" > /etc/apache2/ports.conf
grep -q "^ServerName" /etc/apache2/apache2.conf || echo "ServerName localhost" >> /etc/apache2/apache2.conf

a2enmod rewrite >/dev/null 2>&1 || true
a2ensite 000-default >/dev/null 2>&1 || true

echo "Apache → port ${APP_PORT}, DocumentRoot ${GLPI_DIR}/public ✓"

# ── 5. Cron GLPI ────────────────────────────────────────────────────────────
echo "*/2 * * * * www-data /usr/bin/php ${GLPI_DIR}/front/cron.php &>/dev/null" > /etc/cron.d/glpi
service cron start >/dev/null 2>&1 || true

# ── 6. Apache au premier plan ───────────────────────────────────────────────
pkill -9 apache2 2>/dev/null || true
echo "=== Lancement Apache (port ${APP_PORT}) ==="
exec /usr/sbin/apache2ctl -D FOREGROUND
