# BUILD_REF is the alpine image where we'll install build tools and
BUILD_REF	?= library/alpine:3.10

# MODULE_REF is the output image that will contain module binary
MODULE_REF	?= kernel-module

# KERNEL_REF is the image containing kernel sources for the Docker VM
KERNEL_REF	?= $(shell ruby -ryaml -rjson -e 'puts YAML.load_file("linuxkit.yml").to_json' | jq -r '.kernel.image | @sh')

help:
	@echo To build your module, write a Makefile in the \'module\' directory
	@echo with a default target that will perform the module build.
	@echo
	@echo Then run \'make build\' on your machine to produce a scratch image containing
	@echo the .ko built against your current Docker for Mac environment.

linuxkit.yml:
	docker run --privileged -it --rm --pid host busybox nsenter -t1 -m -- cat /etc/linuxkit.yml > linuxkit.yml

build: linuxkit.yml
	docker build -t $(MODULE_REF) -f Dockerfile \
		--build-arg BUILD_REF=$(BUILD_REF) \
		--build-arg KERNEL_REF=$(KERNEL_REF) \
		.
