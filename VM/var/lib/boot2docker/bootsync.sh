### see: /opt/bootscript.sh

# Link volume before the restart of Gitlab
mkdir -p /srv
ln -s /var/lib/docker/volumes/gitlab/_data /srv/gitlab
