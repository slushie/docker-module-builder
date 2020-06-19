ARG KERNEL_REF
ARG BUILD_REF

FROM ${KERNEL_REF} as kernel-source
FROM ${BUILD_REF} as build

# unpack kernel sources
WORKDIR /usr/src/linuxkit
COPY --from=kernel-source / .
RUN tar xf kernel-dev.tar -C /
RUN tar xf kernel.tar -C /

# install dependencies
RUN apk add -U build-base git curl perl

# copy module sources
WORKDIR /usr/src
COPY module module
RUN make -C module

# copy output
FROM scratch
COPY --from=build /usr/src/module/*.ko .
