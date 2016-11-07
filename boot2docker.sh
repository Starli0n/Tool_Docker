
### Variables
if [ -z ${DOCKER_MACHINE_NAME+x} ]; then
    export DOCKER_MACHINE_NAME=default # if unset set to default
fi

# ANSI COLORS
CRE="$(echo -e '\r\033[K')"
RED="$(echo -e '\033[1;31m')"
GREEN="$(echo -e '\033[1;32m')"
YELLOW="$(echo -e '\033[1;33m')"
BLUE="$(echo -e '\033[1;34m')"
MAGENTA="$(echo -e '\033[1;35m')"
CYAN="$(echo -e '\033[1;36m')"
WHITE="$(echo -e '\033[1;37m')"
NORMAL="$(echo -e '\033[0;39m')"


### Functions

usage () {
cat << EOF
Usage:  $(basename $0)
Helper to improve the management of the Docker VM
                       connect to the VM
  -c, --create-vm      create a new $DOCKER_MACHINE_NAME VM
  -l, --load-images    load all images (*.tar) previously backup in Image directory
  -b, --backup-images  backup all images (*.tar) from the VM to the Image directory
  -s, --sync           synchronize files between host an the VM
  -r, --restart        restart the VM
  -g, --regen-certs    regenerate certs
  -h, --help           display this help and exit
EOF
}

createVM () {
    # Before: delete ~/.docker Except ~/.docker/machine/cache/boot2docker.iso

    # Create a VM in VirtualBox
    echo "${YELLOW}Creating VM..."
    docker-machine create --driver virtualbox $DOCKER_MACHINE_NAME
    eval $(docker-machine env $DOCKER_MACHINE_NAME --shell bash)

    # Copy ssh keys
    echo "${BLUE}Copying SSH Keys..."
    mkdir $HOME/.ssh > /dev/null 2>&1
    cp $HOME/.docker/machine/machines/${DOCKER_MACHINE_NAME}/id_rsa.pub $HOME/.ssh/id_docker_${DOCKER_MACHINE_NAME}_rsa.pub
    cp $HOME/.docker/machine/machines/${DOCKER_MACHINE_NAME}/id_rsa $HOME/.ssh/id_docker_${DOCKER_MACHINE_NAME}_rsa

    echo "${GREEN}Sync files..."
    # Copy bootsync.sh
    docker-machine ssh $DOCKER_MACHINE_NAME "sudo touch /var/lib/boot2docker/bootsync.sh"
    docker-machine ssh $DOCKER_MACHINE_NAME "sudo chmod a+wx /var/lib/boot2docker/bootsync.sh"
    docker-machine scp VM/var/lib/boot2docker/bootsync.sh $DOCKER_MACHINE_NAME:/var/lib/boot2docker

    # Copy bootlocal.sh
    docker-machine ssh $DOCKER_MACHINE_NAME "sudo touch /var/lib/boot2docker/bootlocal.sh"
    docker-machine ssh $DOCKER_MACHINE_NAME "sudo chmod a+wx /var/lib/boot2docker/bootlocal.sh"
    docker-machine scp VM/var/lib/boot2docker/bootlocal.sh $DOCKER_MACHINE_NAME:/var/lib/boot2docker

    # Copy tce.tar
    docker-machine ssh $DOCKER_MACHINE_NAME "sudo touch /var/lib/boot2docker/tce.tar"
    docker-machine ssh $DOCKER_MACHINE_NAME "sudo chmod a+w /var/lib/boot2docker/tce.tar"
    docker-machine scp VM/var/lib/boot2docker/tce.tar $DOCKER_MACHINE_NAME:/var/lib/boot2docker

    # Copy rsub
    docker-machine ssh $DOCKER_MACHINE_NAME "sudo touch /var/lib/boot2docker/rsub"
    docker-machine ssh $DOCKER_MACHINE_NAME "sudo chmod a+wx /var/lib/boot2docker/rsub"
    docker-machine scp VM/var/lib/boot2docker/rsub $DOCKER_MACHINE_NAME:/var/lib/boot2docker

    # Copy .bash_profile
    docker-machine ssh $DOCKER_MACHINE_NAME "sudo touch /var/lib/boot2docker/.bash_profile"
    docker-machine ssh $DOCKER_MACHINE_NAME "sudo chmod a+wx /var/lib/boot2docker/.bash_profile"
    docker-machine scp VM/var/lib/boot2docker/.bash_profile $DOCKER_MACHINE_NAME:/var/lib/boot2docker

    echo "${MAGENTA}Preparing local environment..."
    mkdir -p Shared
    mkdir -p VM/var/lib/boot2docker
    mkdir -p VM/var/lib/docker
    mkdir -p VM/home/docker
    mkdir -p VM/usr/local/etc
    mkdir -p VM/etc

    echo "${WHITE}Done.${NORMAL}"
}

loadImages () {
    eval $(docker-machine env $DOCKER_MACHINE_NAME --shell bash)

    echo "${YELLOW}Loading images..."
    for IMAGE in $(ls -1 Image/*.tar); do
        docker load -i $IMAGE
    done
    echo "${NORMAL}"
}

basckupImages () {
    eval $(docker-machine env $DOCKER_MACHINE_NAME --shell bash)

    echo "${BLUE}Backuping images..."
    for IMAGE in $(docker images --format "{{.Repository}}"); do
        echo $IMAGE
        docker save -o Image/${IMAGE/\//-}.tar $IMAGE  # Replace '/' by '-' in image name
    done
    echo "${NORMAL}"
}

synchro () {
    eval $(docker-machine env $DOCKER_MACHINE_NAME --shell bash)

    echo "${MAGENTA}Sync files..."
    ### Upload
    docker-machine scp VM/var/lib/boot2docker/bootsync.sh $DOCKER_MACHINE_NAME:/var/lib/boot2docker
    docker-machine scp VM/var/lib/boot2docker/bootlocal.sh $DOCKER_MACHINE_NAME:/var/lib/boot2docker
    docker-machine scp VM/var/lib/boot2docker/.bash_profile $DOCKER_MACHINE_NAME:/var/lib/boot2docker

    ### Download
    #docker-machine scp -r $DOCKER_MACHINE_NAME:/home/docker VM/home
    #docker-machine scp $DOCKER_MACHINE_NAME:/usr/local/etc/bashrc VM/usr/local/etc/bashrc
    #docker-machine scp -r $DOCKER_MACHINE_NAME:/opt VM/
    #docker-machine scp -r $DOCKER_MACHINE_NAME:/etc/init.d VM/etc
    #docker-machine scp -r $DOCKER_MACHINE_NAME:/etc/rc.d VM/etc
    echo "-------------------${NORMAL}"
}

regenerate_certs () {
    eval $(docker-machine env $DOCKER_MACHINE_NAME --shell bash)

    echo "${RED}Regenerating certs..."
    docker-machine regenerate-certs $DOCKER_MACHINE_NAME
    cp $HOME/.docker/machine/machines/${DOCKER_MACHINE_NAME}/id_rsa.pub $HOME/.ssh/id_docker_${DOCKER_MACHINE_NAME}_rsa.pub
    cp $HOME/.docker/machine/machines/${DOCKER_MACHINE_NAME}/id_rsa $HOME/.ssh/id_docker_${DOCKER_MACHINE_NAME}_rsa
    echo "-------------------${NORMAL}"
}

boot () {
    echo "${YELLOW}Starting VM..."
    docker-machine start $DOCKER_MACHINE_NAME
    eval $(docker-machine env $DOCKER_MACHINE_NAME --shell bash)
    echo "-------------------"

    synchro
    # docker-machine ssh $DOCKER_MACHINE_NAME "sudo /etc/init.d/docker restart"

    echo "${GREEN}Checking..."
    docker-machine ssh $DOCKER_MACHINE_NAME "cat /var/log/bootlocal.log"
    docker-machine ssh $DOCKER_MACHINE_NAME 'echo - tce.installed: $(ls /usr/local/tce.installed)'
    docker-machine ssh $DOCKER_MACHINE_NAME 'echo - bash: $(which bash)'
    docker-machine ssh $DOCKER_MACHINE_NAME 'echo - rsub: $(which rsub)'
    echo "-------------------"

    echo "${BLUE}Boot2Docker..."
    # docker-machine ssh $DOCKER_MACHINE_NAME
    ssh docker@$(docker-machine ip $DOCKER_MACHINE_NAME) -i $HOME/.ssh/id_docker_${DOCKER_MACHINE_NAME}_rsa
    echo "${NORMAL}"
}

restart () {
    echo "${RED}Stopping VM..."
    docker-machine stop $DOCKER_MACHINE_NAME
    boot
}


### Main

if [ $# -eq 0 ]; then
    B2D=true # Default behavior
fi

# Compute parameters
for i in "$@"; do
case $i in
    -c|--create-vm)     CREATE_VM=true; shift;;
    -l|--load-images)   LOAD_IMAGES=true; shift;;
    -b|--backup-images) BACKUP_IMAGES=true; shift;;
    -s|--sync)          SYNC=true; shift;;
    -r|--restart)       RESTART=true; shift;;
    -g|--regen-certs)   REGEN_CERTS=true; shift;;
    -h|--help)          HELP=true; shift;;
    *)
    # unknown option
    echo $(basename $0): $i: invalid option
    usage
    exit 1
    ;;
esac
done

if [ "$HELP" = true ]; then
    usage
    exit
fi

if [ "$CREATE_VM" = true ]; then
    createVM
fi

if [ "$LOAD_IMAGES" = true ]; then
    loadImages
fi

if [ "$BACKUP_IMAGES" = true ]; then
    basckupImages
fi

if [ "$SYNC" = true ]; then
    synchro
fi

if [ "$RESTART" = true ]; then
    restart
fi

if [ "$REGEN_CERTS" = true ]; then
    regenerate_certs
fi

if [ "$B2D" = true ]; then
    boot
fi
