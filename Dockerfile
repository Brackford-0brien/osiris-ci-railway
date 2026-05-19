FROM diouxx/glpi:latest

# Fichiers Osiris CI (branding + logo)
COPY build/CFG_GLPI.php     /osiris/CFG_GLPI.php
COPY build/osiris_logo.png  /osiris/osiris_logo.png
COPY build/osiris_logo_full.webp /osiris/osiris_logo_full.webp

# Entrypoint personnalisé (génère config_db.php depuis env Railway)
COPY entrypoint.sh /osiris-entrypoint.sh
RUN chmod +x /osiris-entrypoint.sh

# Port Railway
EXPOSE 80

ENTRYPOINT ["/osiris-entrypoint.sh"]
