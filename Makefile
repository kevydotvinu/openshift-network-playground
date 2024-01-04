SHELL=/bin/bash
DIR=$(shell pwd)
ORANGE=\e[0;33m
NOCOLOR=\e[0m
IGNITION_DIR=${DIR}/ignition
OSTREE_IMAGE?=quay.io/onp/onp
REGISTRY=$(shell echo ${OSTREE_IMAGE} | cut -d/ -f1)
RELEASEVER=$(shell curl -s https://raw.githubusercontent.com/coreos/fedora-coreos-config/testing-devel/manifest.yaml | grep releasever:)

check-regcred:
ifndef REGUSER
	$(error REGUSER is undefined)
endif
ifndef REGPASS
	$(error REGPASS is undefined)
endif

check-version:
ifndef VERSION
	$(error VERSION is undefined)
endif

.PHONY: generate-ignition

generate-ignition:
	@echo -e "${ORANGE}Generating 00-core.ign file ...${NOCOLOR}"
	podman run --interactive --rm quay.io/coreos/butane:release --pretty --strict < ${IGNITION_DIR}/00-core.bu > ${IGNITION_DIR}/00-core.ign

.PHONY: update-repo

update-repo:
	@echo -e "${ORANGE}Updating submodule ...${NOCOLOR}"
	git submodule update --remote
	@echo -e "${ORANGE}Removing linked & copied files ...${NOCOLOR}"
	rm -rvf manifest-lock* \
		fedora.repo \
		fedora-coreos-pool.repo \
		image.yaml \
		image-base.yaml \
		manifests \
		overlay.d \
		live \
		platforms.yaml
	@echo -e "${ORANGE}Linking manifest-lock*,image.yaml,image-base.yaml ...${NOCOLOR}"
	ln -svf fedora-coreos-config/manifest-lock* \
		fedora-coreos-config/image.yaml \
		fedora-coreos-config/image-base.yaml \
		fedora-coreos-config/platforms.yaml \
		.
	@echo -e "${ORANGE}Copying fedora.repo & fedora-coreos-pool.repo ...${NOCOLOR}"
	cp -rvf fedora-coreos-config/fedora.repo \
		fedora-coreos-config/fedora-coreos-pool.repo \
		.
	@echo -e "${ORANGE}Linking and copying files from manifests ...${NOCOLOR}"
	mkdir manifests && \
		pushd manifests && \
		ln -svf ../fedora-coreos-config/manifests/* . && \
		rm -rvf fedora-coreos.yaml && \
		cp -rvf ../fedora-coreos-config/manifests/fedora-coreos.yaml . && \
		popd
	@echo -e "${ORANGE}Linking files from overlay.d ...${NOCOLOR}"
	mkdir overlay.d && \
		pushd overlay.d && \
		ln -svf ../fedora-coreos-config/overlay.d/* . && \
		popd
	@echo -e "${ORANGE}Linking and copying files from live ...${NOCOLOR}"
	mkdir live && \
		pushd live && \
		ln -svf ../fedora-coreos-config/live/* . && \
		rm -rvf EFI && \
		mkdir EFI && \
		pushd EFI && \
		ln -svf ../../fedora-coreos-config/live/EFI/* . && \
		rm -rvf fedora && \
		mkdir fedora && \
		pushd fedora && \
		ln -svf ../../../fedora-coreos-config/live/EFI/fedora/* . && \
		rm -rvf grub.cfg && \
		cp -rvf ../../../fedora-coreos-config/live/EFI/fedora/grub.cfg . && \
		popd && \
		popd && \
		rm -rvf isolinux && \
		mkdir isolinux && \
		pushd isolinux && \
		ln -svf ../../fedora-coreos-config/live/isolinux/* . && \
		rm -rvf isolinux.cfg && \
		cp -rvf ../../fedora-coreos-config/live/isolinux/isolinux.cfg . && \
		popd && \
		popd
	@echo -e "${ORANGE}Patching manifest.yaml with releasever ...${NOCOLOR}"
	sed -i "s/releasever.*/${RELEASEVER}/" manifest.yaml
	@echo -e "${ORANGE}Including python3 and python3-libs in manifests/fedora-coreos.yaml ...${NOCOLOR}"
	sed -i 's/^  - python3/#&/' manifests/fedora-coreos.yaml
	@echo -e "${ORANGE}Patching grub.cfg and isolinux.cfg ...${NOCOLOR}"
	sed -i 's/Fedora CoreOS (Live)/OpenShift Network Playground/g' live/EFI/fedora/grub.cfg
	sed -i 's/title Fedora CoreOS/title OpenShift Network Playground/g' live/isolinux/isolinux.cfg
	sed -i 's#label ^Fedora CoreOS (Live)#label ^Autoinstall on /dev/sda#g' live/isolinux/isolinux.cfg

.PHONY: cosa-init

cosa-init:
	@echo -e "${ORANGE}Initializing CoreOS assembler ...${NOCOLOR}"
	-rm -rf ../cosa
	mkdir ../cosa
	podman pull quay.io/coreos-assembler/coreos-assembler:latest
	source ${DIR}/env && \
		pushd ../cosa && \
		unset COREOS_ASSEMBLER_CONFIG_GIT && \
		cosa init https://github.com/kevydotvinu/openshift-network-playground && \
		popd

.PHONY: cosa-run

cosa-run:
	@echo -e "${ORANGE}Building and running FCOS image ...${NOCOLOR}"
	source ${DIR}/env && \
		pushd ../cosa && \
		COREOS_ASSEMBLER_CONFIG_GIT=${DIR} && \
		cosa fetch && \
		cosa build && \
		cosa run && \
		popd

.PHONY: build-ostree

build-ostree:
	@echo -e "${ORANGE}Building ostree container image ...${NOCOLOR}"
	source ${DIR}/env && \
		pushd ../cosa && \
		COREOS_ASSEMBLER_CONFIG_GIT=${DIR} && \
		cosa fetch && \
		cosa build ostree && \
		popd

.PHONY: push-ostree

push-ostree: check-regcred
	@echo -e "${ORANGE}Pushing ostree container image ...${NOCOLOR}"
	source ${DIR}/env && \
		pushd ../cosa && \
		COREOS_ASSEMBLER_CONFIG_GIT=${DIR} && \
		echo "Logging in ${REGISTRY} ..." && \
		podman login --authfile auth.json --username=${REGUSER} --password=${REGPASS} ${REGISTRY} && \
		cosa push-container --authfile auth.json --format oci ${OSTREE_IMAGE} && \
		popd

.PHONY: build-push-ostree

build-push-ostree: check-regcred update-repo cosa-init build-ostree push-ostree


.PHONY: build-iso

build-iso:
	@echo -e "${ORANGE}Building ISO image ...${NOCOLOR}"
	source ${DIR}/env && \
		pushd ../cosa && \
		COREOS_ASSEMBLER_CONFIG_GIT=${DIR} && \
		cosa fetch && \
		cosa build metal && \
		cosa build metal4k && \
		cosa buildextend-live && \
		popd

.PHONY: customize-iso

customize-iso:
	@echo -e "${ORANGE}Customizing ISO image ...${NOCOLOR}"
	source ${DIR}/env && \
		pushd ../ && \
		podman run \
			--security-opt label=disable \
			--pull=always \
			--rm -v .:/data \
			--workdir /data \
			quay.io/coreos/coreos-installer:release iso customize \
			--force \
			--dest-ignition openshift-network-playground/ignition/00-core.ign \
			--dest-device /dev/sda \
			--dest-console tty0 \
			--dest-console ttyS0 \
			--dest-karg-append selinux=0 \
			--live-karg-append console=tty0 \
			--live-karg-append console=ttyS0 \
			cosa/builds/latest/x86_64/fedora-coreos-*-live.x86_64.iso && \
		popd
.PHONY: boot-iso

boot-iso:
	@echo -e "${ORANGE}Booting ISO image ...${NOCOLOR}"
	@qemu-img create ../onp.img 60G
	@virt-install --name onp --vcpu 2 --memory 4000 --disk ../onp.img --cdrom ../cosa/builds/latest/x86_64/*.iso --noautoconsole --graphics spice,listen=0.0.0.0 --boot menu=on

.PHONY: changelog

changelog:
	@hack/changelog.sh

.PHONY: release

release: check-version
	git checkout main
	git fetch origin main
	git merge origin main
	git checkout -b release-${VERSION}
	make update-repo
	git add .
	git commit -m "ci: Release ${VERSION}"
	git push origin release-${VERSION}

.PHONY: tag

tag: check-version
	git tag -s ${VERSION} -m ${VERSION}
	git push origin ${VERSION}

.PHONY: submodule

submodule:
	git submodule update --init --recursive
