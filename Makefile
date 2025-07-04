.PHONY: all ${MAKECMDGOALS}

MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MAKEFILE_DIR := $(dir $(MAKEFILE_PATH))

MOLECULE_SCENARIO ?= binary
MOLECULE_DOCKER_IMAGE ?= ubuntu2204
MOLECULE_DOCKER_COMMAND ?= /lib/systemd/systemd
UBUNTU_RELEASE ?= noble
UBUNTU_KVM_IMAGE = https://cloud-images.ubuntu.com/${UBUNTU_RELEASE}/current/${UBUNTU_RELEASE}-server-cloudimg-amd64.img
MOLECULE_KVM_IMAGE := $(UBUNTU_KVM_IMAGE)
GALAXY_API_KEY ?=
GITHUB_REPOSITORY ?= $$(git config --get remote.origin.url | cut -d: -f 2 | cut -d. -f 1)
GITHUB_ORG = $$(echo ${GITHUB_REPOSITORY} | cut -d/ -f 1)
GITHUB_REPO = $$(echo ${GITHUB_REPOSITORY} | cut -d/ -f 2)
REQUIREMENTS = requirements.yml
ROLE_DIR = roles
ROLE_FILE = roles.yml
COLLECTION_NAMESPACE = $$(yq '.namespace' < galaxy.yml)
COLLECTION_NAME = $$(yq '.name' < galaxy.yml)
COLLECTION_VERSION = $$(yq '.version' < galaxy.yml)

LOGIN_ARGS ?=

all: install version lint test

ubuntu:
	make dependency create prepare \
		MOLECULE_KVM_IMAGE=${UBUNTU_KVM_IMAGE} \
		MOLECULE_SCENARIO=${MOLECULE_SCENARIO}

noble ubuntu2404:
	make ubuntu UBUNTU_RELEASE=noble MOLECULE_SCENARIO=${MOLECULE_SCENARIO}

jammy ubuntu2204:
	make ubuntu UBUNTU_RELEASE=jammy MOLECULE_SCENARIO=${MOLECULE_SCENARIO}

focal ubuntu2004:
	make ubuntu UBUNTU_RELEASE=focal MOLECULE_SCENARIO=${MOLECULE_SCENARIO}

test: requirements
	ANSIBLE_COLLECTIONS_PATH=$(MAKEFILE_DIR) \
	MOLECULE_KVM_IMAGE=${MOLECULE_KVM_IMAGE} \
	uv run molecule test -s ${MOLECULE_SCENARIO}

install:
	@uv sync

lint: requirements
	uv run yamllint . -c .yamllint
	ANSIBLE_COLLECTIONS_PATH=$(MAKEFILE_DIR) \
	uv run ansible-lint playbooks/

requirements: install
	@yq '.roles[].name' -r < roles.yml | xargs -I {} rm -rf roles/{}
	@python --version
	@uv run ansible-galaxy role install \
		--force --no-deps \
		--roles-path ${ROLE_DIR} \
		--role-file ${ROLE_FILE}
	ANSIBLE_COLLECTIONS_PATH=$(MAKEFILE_DIR) \
	uv run ansible-galaxy collection install \
		--force-with-deps .
	@\find ./ -name "*.ymle*" -delete

build: requirements
	@uv run ansible-galaxy collection build --force

dependency create prepare converge idempotence side-effect verify destroy cleanup reset list:
	rm -rf ansible_collections/
	ANSIBLE_COLLECTIONS_PATH=$(MAKEFILE_DIR) \
	MOLECULE_KVM_IMAGE=${MOLECULE_KVM_IMAGE} \
	MOLECULE_DOCKER_COMMAND=${MOLECULE_DOCKER_COMMAND} \
	MOLECULE_DOCKER_IMAGE=${MOLECULE_DOCKER_IMAGE} \
	uv run molecule $@ -s ${MOLECULE_SCENARIO}

ifeq (login,$(firstword $(MAKECMDGOALS)))
    LOGIN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
    $(eval $(subst $(space),,$(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))):;@:)
endif

login:
	MOLECULE_KVM_IMAGE=${MOLECULE_KVM_IMAGE} \
	MOLECULE_DOCKER_COMMAND=${MOLECULE_DOCKER_COMMAND} \
	MOLECULE_DOCKER_IMAGE=${MOLECULE_DOCKER_IMAGE} \
	uv run molecule $@ -s ${MOLECULE_SCENARIO} ${LOGIN_ARGS}

ignore:
	@uv run ansible-lint --generate-ignore

clean: destroy reset
	@uv env remove $$(which python) >/dev/null 2>&1 || exit 0

publish: build
	uv run ansible-galaxy collection publish --api-key ${GALAXY_API_KEY} \
		"${COLLECTION_NAMESPACE}-${COLLECTION_NAME}-${COLLECTION_VERSION}.tar.gz"

version:
	@uv run molecule --version
