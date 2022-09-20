#!/bin/bash
set -e -o pipefail

: "${REGISTRY:=core.harbor.vaimo-sa-cloud.co.za/library}"

if [[ -n $GIT_TAG ]]; then
    TAG=${GIT_TAG/v/}
    echo "publish $TAG"
	docker tag ${REGISTRY}/jenkins-jnlp-slave ${REGISTRY}/jenkins-jnlp-slave:${TAG}
	docker push ${REGISTRY}/jenkins-jnlp-slave:${TAG}

else
    echo "publish latest"
	docker push ${REGISTRY}/jenkins-jnlp-slave
fi
