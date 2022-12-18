#tag=dev
#arch=amd64
#version=7137a23-dirty
#repo=k3os
K3OS_VERSION=v0.0.0

build () {
    tag=$1-$2
    arch=$2
    version=$3
    repo=$4

    #build the base image. depends on
    docker build -t $repo/base:$tag --file=images/base.Dockerfile --build-arg ARCH=$arch --build-arg REPO=$repo --build-arg TAG=$tag --build-arg VERSION=$version .
    #build the gobuild image. depends on 
    docker build -t $repo/gobuild:$tag --file=images/gobuild.Dockerfile --build-arg ARCH=$arch --build-arg REPO=$repo --build-arg TAG=$tag --build-arg VERSION=$version .
    #build the k3s image. depends on base
    docker build -t $repo/k3s:$tag --file=images/k3s.Dockerfile --build-arg ARCH=$arch --build-arg REPO=$repo --build-arg TAG=$tag --build-arg VERSION=$version .
    #build the progs image. depends on gobuild
    docker build -t $repo/progs:$tag --file=images/progs.Dockerfile --build-arg ARCH=$arch --build-arg REPO=$repo --build-arg TAG=$tag --build-arg VERSION=$version .
    #build the rootfs image. depends on base, progs, k3s
    docker build -t $repo/rootfs:$tag --file=images/rootfs.Dockerfile --build-arg ARCH=$arch --build-arg REPO=$repo --build-arg TAG=$tag --build-arg VERSION=$version .
    #build the bin image. depends on base, rootfs, progs
    docker build -t $repo/bin:$tag --file=images/bin.Dockerfile --build-arg ARCH=$arch --build-arg REPO=$repo --build-arg TAG=$tag --build-arg VERSION=$version .
    #build the kernel image. depends on bin, base
    docker build -t $repo/kernel:$tag --file=images/kernel.Dockerfile --build-arg ARCH=$arch --build-arg REPO=$repo --build-arg TAG=$tag --build-arg VERSION=$version .
    #build the package image. depends on base, bin, k3s, kernel
    docker build -t $repo/package:$tag --file=images/package.Dockerfile --build-arg ARCH=$arch --build-arg REPO=$repo --build-arg TAG=$tag --build-arg VERSION=$version .
    #build the iso image. depends on base, package
    docker build -t $repo/iso:$tag --file=images/iso.Dockerfile --build-arg ARCH=$arch --build-arg REPO=$repo --build-arg TAG=$tag --build-arg VERSION=$version .
}

build_pc () {
    build dev amd64 $K3OS_VERSION k3os
}

build_pi () {
    build dev arm64 $K3OS_VERSION k3os-pi
    docker build -t k3os-pi/rpi:dev-arm64 --file=images/rpi.Dockerfile --build-arg ARCH=arm64 --build-arg REPO=k3os-pi --build-arg TAG=dev-arm64 --build-arg VERSION=$K3OS_VERSION .
    docker run -v /dev:/dev -v ${PWD}/output:/output --privileged k3os-pi/rpi:dev-arm64
}

#build_pc
build_pi

# nerdctl build -t k3os/kernel --file=images/k3os-kernel.Dockerfile .
# nerdctl build -t k3os/base --file=images/k3os-base.Dockerfile .
# nerdctl build -t k3os/gobuild --file=images/k3os-gobuild.Dockerfile .
