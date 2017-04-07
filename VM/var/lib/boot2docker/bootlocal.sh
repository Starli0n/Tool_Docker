### see: /opt/bootscript.sh

# Install bash
tar -xf /var/lib/boot2docker/tce.tar -C /tmp/tce/optional/
su - docker -c "tce-load -i bash.tcz"

# Install rsub
ln -s /var/lib/boot2docker/rsub /usr/local/bin/rsub

# Mount a shared folder
mkdir -p /var/shared/default
mount -t vboxsf -o defaults,uid=`id -u docker`,gid=`id -g docker` Default /var/shared/default

# Mount a gitlab shared folder
mkdir -p /var/shared/gitlab/backups
mount -t vboxsf -o defaults,uid=`id -u docker`,gid=`id -g docker` Gitlab /var/shared/gitlab

# Mount a web shared folder
mkdir -p /var/shared/web
mount -t vboxsf Web /var/shared/web

# Custom docker home profile
ln -s /var/lib/boot2docker/.bash_profile /home/docker/.bash_profile
echo '' >> /home/docker/.ashrc
echo 'if [ -f $HOME/.bash_profile ]; then' >> /home/docker/.ashrc
echo '    . $HOME/.bash_profile' >> /home/docker/.ashrc
echo 'fi' >> /home/docker/.ashrc

# Custom root home profile (> sudo -i)
ln -s /home/docker/.ashrc /root/.ashrc
ln -s /var/lib/boot2docker/.bash_profile /root/.bash_profile
echo '' >> /root/.profile
echo 'if [ -f $HOME/.ashrc ]; then' >> /root/.profile
echo '    . $HOME/.ashrc' >> /root/.profile
echo 'fi' >> /root/.profile
