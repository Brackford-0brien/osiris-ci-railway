FROM diouxx/glpi:latest

# Fix Apache : DocumentRoot → /public (requis GLPI 10+)
# Fait au BUILD pour ne pas être écrasé par /opt/glpi-start.sh
COPY apache-glpi.conf /etc/apache2/sites-available/glpi.conf
RUN a2dissite 000-default 2>/dev/null || true \
    && a2ensite glpi \
    && a2enmod rewrite

# Fichiers Osiris CI (branding + logo + app_name)
COPY build/CFG_GLPI.php          /osiris/CFG_GLPI.php
COPY build/osiris_logo.png       /osiris/osiris_logo.png
COPY build/osiris_logo_full.webp /osiris/osiris_logo_full.webp

# Entrypoint personnalisé
COPY entrypoint.sh /osiris-entrypoint.sh
RUN chmod +x /osiris-entrypoint.sh

EXPOSE 80
ENTRYPOINT ["/osiris-entrypoint.sh"]
