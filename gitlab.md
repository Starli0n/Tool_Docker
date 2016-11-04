```

# Preparing the VM
docker volume create --name gitlab
docker-machine ssh default "sudo mkdir /var/lib/docker/volumes/gitlab/_data/config"
docker-machine ssh default "sudo mkdir /var/lib/docker/volumes/gitlab/_data/logs"
docker-machine ssh default "sudo mkdir /var/lib/docker/volumes/gitlab/_data/data"

# Run gitlab
docker run --detach --hostname gitlab.example.com --publish 443:443 --publish 80:80 --publish 2222:22 --name gitlab --restart always --volume /srv/gitlab/config:/etc/gitlab --volume /srv/gitlab/logs:/var/log/gitlab --volume /srv/gitlab/data:/var/opt/gitlab gitlab/gitlab-ce:latest

# Backup data into a shared folder
docker-machine ssh default "cd /srv/gitlab && sudo tar -cf /var/shared/default/gitlab.tar *"
```
