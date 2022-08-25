.PHONY: default
UPSTREAM_VERSION_FILE = UPSTREAM_VERSION.txt
UPSTREAM_VERSION = `cat $(UPSTREAM_VERSION_FILE)`
DEFAULT_BUILD_ARGS = --build-arg http_proxy=$(http_proxy) --build-arg https_proxy=$(https_proxy) --build-arg no_proxy=$(no_proxy)
REGISTRY = registry.vaimo-sa-cloud.co.za
default: build-alpine

build:
	docker build --platform linux/amd64 --rm --force-rm -t $(REGISTRY)/jenkins-jnlp-slave:alpine $(DEFAULT_BUILD_ARGS) --build-arg=FROM_TAG=$(UPSTREAM_VERSION)-alpine .
	docker tag $(REGISTRY)/jenkins-jnlp-slave:alpine $(REGISTRY)/jenkins-jnlp-slave:latest

run: build
	docker run -it $(REGISTRY)/jenkins-jnlp-slave:alpine

publish: build
	./publish.sh

release:
	$(eval NEW_INCREMENT := $(shell expr `git describe --tags --abbrev=0 | cut -d'-' -f3` + 1))
	git tag v$(UPSTREAM_VERSION)-$(NEW_INCREMENT)
	git push origin v$(UPSTREAM_VERSION)-$(NEW_INCREMENT)
