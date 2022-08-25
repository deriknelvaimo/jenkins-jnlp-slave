#!/bin/bash
set -e -o pipefail

## Run wrapdocker if DIND=true
if [ "$DIND" == "true" ]; then
    echo "DIND=true, running wrapdocker $0 \"$@\""
    unset DIND
    exec wrapdocker $0 "$@"
fi

if [ "$(id -u)" == "0" ]; then
    # To enable docker cloud based on docker socket,
    # we need to add jenkins user to the docker group
    if [ -S /var/run/docker.sock ]; then
        DOCKER_SOCKET_OWNER_GROUP_ID=$(stat -c %g /var/run/docker.sock)
        groupadd -for -g ${DOCKER_SOCKET_OWNER_GROUP_ID} docker
        id jenkins -G -n | grep docker || usermod -aG docker jenkins
    fi

    dirs=(
        '/home/jenkins/tools'
        '/home/jenkins/.m2'
        '/home/jenkins/.gradle'
        '/home/jenkins/.gradle/caches'
        '/home/jenkins/.gradle/caches/modules-2'
        '/home/jenkins/.gradle/native'
        '/home/jenkins/.gradle/wrapper'
        '/home/jenkins/.coursier'
        '/home/jenkins/.ivy'
        '/home/jenkins/.sbt'
        '/home/jenkins'
    )
    for d in ${dirs[@]}; do
        if [[ -d $d ]] && [[ "$(stat -c %u $d)" != "$(id -u jenkins)" ]]; then
            echo "chown jenkins:jenkins $d"
            chown jenkins:jenkins $d
            echo "chown jenkins:jenkins $d... Done"
        fi
    done
fi

eval $(ssh-agent) > /dev/null
ssh-add /root/.ssh/id_rsa || true
chown -R root:jenkins $(dirname $SSH_AUTH_SOCK) && chmod 750 $(dirname $SSH_AUTH_SOCK) && chmod 640 $(readlink -f $SSH_AUTH_SOCK)
# jenkins agent clears env variables
echo -n "$SSH_AUTH_SOCK" > /tmp/SSH_AUTH_SOCK_LOCATION

exec gosu jenkins "jenkins-slave" "$@"