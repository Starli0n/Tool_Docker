```
# Note:
# docker-machine commands are executed from the host
# docker             "     "     "       "  the host or the docker VM
# gitlab*            "     "     "       "  the container

# Note about shells:
# - Host shell
cd $Tools/Docker
# - docker VM shell (from host shell)
btd # First connection of the session
dsh # Quick connection
# - Gitlab container shell (from host or docker VM shell)
docker exec -it gitlab /bin/bash

---

# Initialize the docker machine environment
ddefault or deprod or dvm $DOCKER_MACHINE_NAME

# Create the VM
btdinit

# Preparing the VM
# In VirtualBox, the folders would be automatically mapped to the fodler of the VM
# Create a shared folders "$Tools/Docker/Shared/Default"         -->> /var/shared/default
# Create a shared folders "$Tools/Docker/Shared/Gitlab/backups"  -->> /var/shared/gitlab/backups

# Create a gitlab volume for data persistence
docker volume create --name gitlab
docker-machine ssh $DOCKER_MACHINE_NAME "sudo mkdir -p /var/lib/docker/volumes/gitlab/_data/config"
docker-machine ssh $DOCKER_MACHINE_NAME "sudo mkdir -p /var/lib/docker/volumes/gitlab/_data/logs"
docker-machine ssh $DOCKER_MACHINE_NAME "sudo mkdir -p /var/lib/docker/volumes/gitlab/_data/data"

# Connection to the VM for the first time of the session
btd

# Check the existence of the folders
dsh     # Quick connection to the VM
si      # Admin
cd /var/lib/docker/volumes/gitlab/_data
l

# Run gitlab
# VM                 : Container
# /srv/gitlab/config : /etc/gitlab
# /srv/gitlab/logs   : /var/log/gitlab
# /srv/gitlab/data   : /var/opt/gitlab
docker run --detach --hostname gitlab.example.com --publish 443:443 --publish 80:80 --publish 22:22 --name gitlab --restart always --volume /srv/gitlab/config:/etc/gitlab --volume /srv/gitlab/logs:/var/log/gitlab --volume /srv/gitlab/data:/var/opt/gitlab gitlab/gitlab-ce:latest

# Create SSL certificates in the VM
mkdir -p /srv/gitlab/config/ssl
chmod 700 /srv/gitlab/config/ssl
cd /srv/gitlab/config/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /srv/gitlab/config/ssl/gitlab.example.com.key -out /srv/gitlab/config/ssl/gitlab.example.crt
    FR
    France
    Paris
    Gitlab
    Gitlab
    gitlab.example.com
    gitlab@no-reply.com

# Config
rsub /srv/gitlab/config/gitlab.rb
external_url "https://gitlab.example.com"
nginx['redirect_http_to_https'] = true
nginx['ssl_certificate'] = "/etc/gitlab/ssl/gitlab.example.crt"
nginx['ssl_certificate_key'] = "/etc/gitlab/ssl/gitlab.example.com.key"

# VirtualBox - Port Forwarding (no restart needed)
Gitlab           TCP    <HOST-IP>    80     ¤    80
Gitlab Secure    TCP    <HOST-IP>    443    ¤    443

# /etc/hosts (only to bind the name)
<HOST-IP>    gitlab.example.com

# Restart
docker restart gitlab

# Curl test
> curl --insecure https://<HOST-IP>
> curl --insecure https://gitlab.example.com
<html><body>You are being <a href="https://gitlab.example.com/users/sign_in">redirected</a>.</body></html>

# Logs
docker logs gitlab

# Default repository storage
# /srv/gitlab/data/git-data/repositories : /var/opt/gitlab/git-data/repositories

# Create a backup
# gitlab_rails['backup_path'] =
# /srv/gitlab/data/backups               : /var/opt/gitlab/backups
# /srv/gitlab/config/gitlab-secrets.json : /etc/gitlab/gitlab-secrets.json
docker exec -t gitlab gitlab-rake gitlab:backup:create
docker-machine ssh $DOCKER_MACHINE_NAME "sudo cp -r /srv/gitlab/data/backups /var/shared/gitlab"
# Backup config: gitlab.rb, gitlab-secrets.json, ssl and Co
docker-machine ssh $DOCKER_MACHINE_NAME "sudo cp -r /srv/gitlab/config /var/shared/gitlab/backups"

# Restore a backup
# Note: the restore should be from an up and running gitlab
# Open 2 terminals: from the host and from the gitlab container
docker-machine ssh $DOCKER_MACHINE_NAME "sudo cp -r /var/shared/gitlab/backups/<backup-id>_gitlab_backup.tar /srv/gitlab/data/backups"
# Restore backup
docker exec -it gitlab /bin/bash
chmod -R 775 /var/opt/gitlab/backups
gitlab-ctl stop unicorn
gitlab-ctl stop sidekiq
gitlab-ctl status # Verify
# This command will overwrite the contents of your GitLab database!
gitlab-rake gitlab:backup:restore BACKUP=<backup-id>
chown -R git /var/opt/gitlab/gitlab-rails/uploads
# Restore config: gitlab.rb, gitlab-secrets.json, ssl and Co
docker-machine ssh $DOCKER_MACHINE_NAME "sudo cp -r /var/shared/gitlab/backups/config /srv/gitlab"
# Restart Gitlab
gitlab-ctl reconfigure
gitlab-ctl start
gitlab-rake gitlab:check SANITIZE=true

# Raw backup data into a shared folder
docker-machine ssh $DOCKER_MACHINE_NAME "cd /srv/gitlab && sudo tar -cf /var/shared/default/gitlab.tar *"
```
