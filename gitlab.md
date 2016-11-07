```
export $DOCKER_MACHINE_NAME=default

# Preparing the VM
docker volume create --name gitlab
docker-machine ssh $DOCKER_MACHINE_NAME "sudo mkdir /var/lib/docker/volumes/gitlab/_data/config"
docker-machine ssh $DOCKER_MACHINE_NAME "sudo mkdir /var/lib/docker/volumes/gitlab/_data/logs"
docker-machine ssh $DOCKER_MACHINE_NAME "sudo mkdir /var/lib/docker/volumes/gitlab/_data/data"

# Run gitlab
docker run --detach --hostname gitlab.example.com --publish 443:443 --publish 80:80 --publish 2222:22 --name gitlab --restart always --volume /srv/gitlab/config:/etc/gitlab --volume /srv/gitlab/logs:/var/log/gitlab --volume /srv/gitlab/data:/var/opt/gitlab gitlab/gitlab-ce:latest

# Shell
docker exec -it gitlab /bin/bash

# Create a backup /srv/gitlab/data/backups:/var/opt/gitlab/backups
docker exec -t gitlab gitlab-rake gitlab:backup:create
docker-machine ssh $DOCKER_MACHINE_NAME "sudo cp -r /srv/gitlab/data/backups /var/shared/default"

# Restore a backup
gitlab-ctl stop unicorn
gitlab-ctl stop sidekiq
gitlab-ctl status # Verify
# This command will overwrite the contents of your GitLab database!
gitlab-rake gitlab:backup:restore BACKUP=<backup-id>
gitlab-ctl start
gitlab-rake gitlab:check SANITIZE=true

# Raw backup data into a shared folder
docker-machine ssh $DOCKER_MACHINE_NAME "cd /srv/gitlab && sudo tar -cf /var/shared/default/gitlab.tar *"
```
