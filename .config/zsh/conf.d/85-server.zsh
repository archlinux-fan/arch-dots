# --- Server ------------------------------------------------------------------
# Logged in over ssh on a Docker host: start in the folder with the compose stacks.
if [[ -n "$SSH_CONNECTION" && -d /srv/docker-compose ]]; then
    cd /srv/docker-compose/
    lsa
fi
