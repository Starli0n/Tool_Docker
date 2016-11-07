# .bash_profile

echo "${NORMAL}"

################
### VARIABLE ###
################

export BASH_FILE="$HOME/.bash_profile"
export BOOT2DOCKER="/var/lib/boot2docker"
export DOCKER="/var/lib/docker"
export DOCKER_VOLUMES="/var/lib/docker/volumes"
export EDITOR='rsub'


#############
### ALIAS ###
#############

### aliases
alias ralias='source $BASH_FILE'
alias aliases='$EDITOR $BASH_FILE'
alias aliash='cat $BASH_FILE'

### Shell
alias cls='clear'
alias l='ls -pla'
alias spath='echo -e ${PATH//:/\\n}'
alias lib='echo -e ${LD_LIBRARY_PATH//:/\\n}'
alias ..='cd ..'
alias cd..='cd ..'
alias setv='_setv(){ env | grep ^$1; }; _setv'
alias h='cat $HOME/.ash_history'
alias clsh='cat /dev/null>$HOME/.ash_history'
alias tit='_tit(){ echo -ne "\033]$mode;$*\007"; }; _tit'
alias si='sudo -i'

### Sublime Text
alias subl='$EDITOR'

### Directory
alias btd='cd $BOOT2DOCKER'
alias doc='cd $DOCKER'
alias vol='cd $DOCKER_VOLUMES'

### docker
alias d='docker'
alias dr='docker run'
alias drn='docker run --name'
alias dri='docker run -it'
alias dh='_dh(){ docker $* --help; }; _dh'
alias dhw='docker run hello-world'
alias duber='docker run -dit --name uber --volume /var/shared/default:/var/shared ubuntu /bin/bash'
alias dbh='_dbh(){ docker exec -it $* /bin/bash; }; _dbh'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias dpse='docker ps --filter status=exited'
alias dpsl='docker ps -lq'
alias dl='docker logs -f'
alias di='docker images'
alias dp='docker pull'
alias ddt='docker diff'
alias dci='docker commit'
alias ds='_ds(){ pushd $DOCKER_HOME; docker save -o Image/${1/\//-}.tar $1; popd; }; _ds' # Replace '/' by '-' in image name
alias dload='_ds(){ pushd $DOCKER_HOME; docker load -i Image/$1.tar; popd; }; _ds'
alias drm='docker rm -f'
alias drme='docker rm $(docker ps --filter status=exited --quiet)'
alias drmi='docker rmi'
alias drmid='docker rmi $(docker images -f "dangling=true" -q)'
alias dinf='docker info'
alias dv='docker version'
