FROM diouxx/glpi:latest

# GLPI 11.0.7 figé au BUILD (correspond au schéma du dump SQL importé).
# L'image diouxx télécharge la LATEST au runtime → on l'évite pour garantir
# que le code matche la base de données.
RUN cd /var/www/html \
    && wget -q https://github.com/glpi-project/glpi/releases/download/11.0.7/glpi-11.0.7.tgz \
    && tar -xzf glpi-11.0.7.tgz -C /var/www/html \
    && rm -f glpi-11.0.7.tgz \
    && chown -R www-data:www-data /var/www/html/glpi

# Fichiers Osiris CI (branding + logo + app_name)
COPY build/CFG_GLPI.php          /osiris/CFG_GLPI.php
COPY build/osiris_logo.png       /osiris/osiris_logo.png
COPY build/osiris_logo_full.webp /osiris/osiris_logo_full.webp

# Entrypoint auto-suffisant (ne dépend plus de /opt/glpi-start.sh)
COPY entrypoint.sh /osiris-entrypoint.sh
RUN chmod +x /osiris-entrypoint.sh

EXPOSE 80
ENTRYPOINT ["/osiris-entrypoint.sh"]
