#!/bin/bash
set -e -o pipefail

: "${REGISTRY:=registry.vaimo-sa-cloud.co.za}"

echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin ${REGISTRY}

if [[ -n $GIT_TAG ]]; then
    TAG=${GIT_TAG/v/}
    echo "publish $TAG"
	docker tag ${REGISTRY}/jenkins-jnlp-slave ${REGISTRY}/jenkins-jnlp-slave:${TAG}
	docker tag ${REGISTRY}/jenkins-jnlp-slave:alpine ${REGISTRY}/jenkins-jnlp-slave:${TAG}-alpine
	#docker tag ${REGISTRY}/jenkins-jnlp-slave:debian ${REGISTRY}/jenkins-jnlp-slave:${TAG}-debian
	#docker tag ${REGISTRY}/jenkins-jnlp-slave:jdk11 ${REGISTRY}/jenkins-jnlp-slave:${TAG}-jdk11
	docker push ${REGISTRY}/jenkins-jnlp-slave:${TAG}
	docker push ${REGISTRY}/jenkins-jnlp-slave:${TAG}-alpine
	#docker push ${REGISTRY}/jenkins-jnlp-slave:${TAG}-debian
	#docker push ${REGISTRY}/jenkins-jnlp-slave:${TAG}-jdk11

else
    echo "publish latest"
	docker push ${REGISTRY}/jenkins-jnlp-slave
	docker push ${REGISTRY}/jenkins-jnlp-slave:alpine
	#docker push ${REGISTRY}/jenkins-jnlp-slave:debian
	#docker push ${REGISTRY}/jenkins-jnlp-slave:jdk11
fi