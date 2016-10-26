
### Variables

VM_B2D=var/lib/boot2docker
VM_DOCKER=var/lib/docker
VM_UETC=usr/local/etc

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
  -c, --create-vm      create a new default VM
  -l, --load-images    load all images (*.tar) previously backup in Image directory
  -b, --backup-images  backup all images (*.tar) from the VM to the Image directory
  -s, --sync           synchronize files between host an the VM
  -r, --restart        restart the VM
  -h, --help           display this help and exit
EOF
}

createVM () {
    # Before: delete ~/.docker Except ~/.docker/machine/cache/boot2docker.iso

    # Create a VM in VirtualBox
    echo "${YELLOW}Creating VM..."
    docker-machine create --driver virtualbox default
    eval $(docker-machine env default --shell bash)

    # Copy ssh keys
    echo "${BLUE}Copying SSH Keys..."
    mkdir $HOME/.ssh > /dev/null 2>&1
    cp $HOME/.docker/machine/machines/default/id_rsa.pub $HOME/.ssh/id_docker_rsa.pub
    cp $HOME/.docker/machine/machines/default/id_rsa $HOME/.ssh/id_docker_rsa

    echo "${GREEN}Sync files..."
    # Copy bootsync.sh
    #docker-machine ssh default "sudo touch /$VM_B2D/bootsync.sh"
    #docker-machine ssh default "sudo chmod a+wx /$VM_B2D/bootsync.sh"
    #docker-machine scp VM/$VM_B2D/bootsync.sh default:/$VM_B2D

    # Copy bootlocal.sh
    docker-machine ssh default "sudo touch /$VM_B2D/bootlocal.sh"
    docker-machine ssh default "sudo chmod a+wx /$VM_B2D/bootlocal.sh"
    docker-machine scp VM/$VM_B2D/bootlocal.sh default:/$VM_B2D

    # Copy tce.tar
    docker-machine ssh default "sudo touch /$VM_B2D/tce.tar"
    docker-machine ssh default "sudo chmod a+w /$VM_B2D/tce.tar"
    docker-machine scp VM/$VM_B2D/tce.tar default:/$VM_B2D

    # Copy rsub
    docker-machine ssh default "sudo touch /$VM_B2D/rsub"
    docker-machine ssh default "sudo chmod a+wx /$VM_B2D/rsub"
    docker-machine scp VM/$VM_B2D/rsub default:/$VM_B2D

    # Copy .bash_profile
    docker-machine ssh default "sudo touch /$VM_B2D/.bash_profile"
    docker-machine ssh default "sudo chmod a+wx /$VM_B2D/.bash_profile"
    docker-machine scp VM/$VM_B2D/.bash_profile default:/$VM_B2D

    echo "${MAGENTA}Preparing local environment..."
    mkdir -p Shared
    mkdir -p VM/$VM_B2D
    mkdir -p VM/$VM_DOCKER
    mkdir -p VM/home/docker
    mkdir -p VM/$VM_UETC
    mkdir -p VM/etc

    echo "${WHITE}Done.${NORMAL}"
}

loadImages () {
    eval $(docker-machine env default --shell bash)

    echo "${YELLOW}Loading images..."
    for IMAGE in $(ls -1 Image/*.tar); do
        docker load -i $IMAGE
    done
    echo "${NORMAL}"
}

basckupImages () {
    eval $(docker-machine env default --shell bash)

    echo "${BLUE}Backuping images..."
    for IMAGE in $(docker images --format "{{.Repository}}"); do
        echo $IMAGE
        docker save -o Image/${IMAGE/\//-}.tar $IMAGE  # Replace '/' by '-' in image name
    done
    echo "${NORMAL}"
}

synchro () {
    eval $(docker-machine env default --shell bash)

    echo "${MAGENTA}Sync files..."
    ### Upload
    #docker-machine scp VM/$VM_B2D/bootsync.sh default:/$VM_B2D
    docker-machine scp VM/$VM_B2D/bootlocal.sh default:/$VM_B2D
    docker-machine scp VM/$VM_B2D/.bash_profile default:/$VM_B2D

    ### Download
    #docker-machine scp -r default:/home/docker VM/home
    #docker-machine scp default:/$VM_UETC/bashrc VM/$VM_UETC/bashrc
    #docker-machine scp -r default:/opt VM/
    #docker-machine scp -r default:/etc/init.d VM/etc
    #docker-machine scp -r default:/etc/rc.d VM/etc
    echo "-------------------${NORMAL}"
}

boot () {
    echo "${YELLOW}Starting VM..."
    docker-machine start default
    eval $(docker-machine env default --shell bash)
    echo "-------------------"

    synchro
    # docker-machine ssh default "sudo /etc/init.d/docker restart"

    echo "${GREEN}Checking..."
    docker-machine ssh default "cat /var/log/bootlocal.log"
    docker-machine ssh default 'echo - tce.installed: $(ls /usr/local/tce.installed)'
    docker-machine ssh default 'echo - bash: $(which bash)'
    docker-machine ssh default 'echo - rsub: $(which rsub)'
    echo "-------------------"

    echo "${BLUE}Boot2Docker..."
    # docker-machine ssh default
    ssh docker@$(docker-machine ip default) -i $HOME/.ssh/id_docker_rsa
    echo "${NORMAL}"
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

if [ "$B2D" = true ]; then
    boot
fi
