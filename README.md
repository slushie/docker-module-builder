# docker-module-builder
Build kernel modules for Docker for Mac and Docker for Windows -- now called Docker Desktop.

This repo contains a simple recipe to build kernel modules that can be loaded into
the kernel of the Docker Desktop VM. 

## Usage

Place a `Makefile` and any additional sources you need into the `module` directory. It will
be copied into a Docker build container at `/usr/src/module` and the default make target 
will be run from that directory. 

Once your module is built, make sure your make target copies the output `.ko` binary files
into `/usr/src/module`. Those binaries will be copied into the resulting scratch image.

Once your `module/Makefile` is ready, you can use the `make build` target in this repo to
start the build!

### Options

There are a few options you can specify to `make build`.

* **`BUILD_REF`** is the image used to perform the build. Your `BUILD_REF` must provide 
  the same version of `gcc` used to compile the target kernel. NB: The Docker Desktop VM 
  runs Alpine Linux, which uses `musl-libc`. The default value is `library/alpine:3.10`
  which has been tested to work on Docker Desktop `2.3.0.2`.

* **`KERNEL_REF`** is the image that contains kernel sources packaged as part of the 
  Docker Desktop VM's build. Docker, Inc. currently publishes sources to Docker Hub. If
  this value is not set, the `Makefile` can fetch data about the build environment by 
  running a privileged container. You can leave it unset if you're comfortable with the 
  default behaviour.

* **`MODULE_REF`** is the output image ref. It is a scratch image that contains only 
  the built `.ko` binaries. The default is `kernel-module`.


## Rationale

Docker Desktop has recently (starting in `2.3.0.2`) removed a number of kernel modules 
from the VM they provide. This change has broken a number of containers that rely on modules
previously shipped with Docker Desktop. Although Docker, Inc. has never provided any 
explicit interface for the VM's Linux environment, this change has caught many people by 
surprise and broken many existing containers.

It's important to also note that Docker Desktop _does not version_ the VM separately from
the other components in the Docker Desktop product. So despite this breaking change, the
only indicator in `docker version` that can be used to detect the missing features is the
`Built:` date value.

## See Also

There are many kernel modules missing from the latest Docker Desktop release. Here are
a few GitHub issues that report missing modules. You'll note that most have been 
ignored by Docker, Inc.

* [#4552](https://github.com/docker/for-mac/issues/4552) `sctp` module.
* [#4560](https://github.com/docker/for-mac/issues/4560) `wireguard` module.
* [#4581](https://github.com/docker/for-mac/issues/4581) `drm` support for the 
  `radeon`, `i915`, `nouveau` modules.
* [#4660](https://github.com/docker/for-mac/issues/4660) `openvswitch` module.
* [#4549](https://github.com/docker/for-mac/issues/4549) `device-mapper` modules. This
  issue was immediately resolved in the next release of Docker Desktop.
