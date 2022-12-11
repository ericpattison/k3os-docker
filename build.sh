tag=dev
arch=amd64
version=7137a23-dirty
repo=k3os

#build the base image. depends on
docker build -t k3os/base:$tag --file=images/base.Dockerfile --build-arg ARCH=$arch --build-arg REPO=$repo --build-arg TAG=$tag --build-arg VERSION=$version .
#build the gobuild image. depends on 
docker build -t k3os/gobuild:$tag --file=images/gobuild.Dockerfile --build-arg ARCH=$arch --build-arg REPO=$repo --build-arg TAG=$tag --build-arg VERSION=$version .
#build the k3s image. depends on base
docker build -t k3os/k3s:$tag --file=images/k3s.Dockerfile --build-arg ARCH=$arch --build-arg REPO=$repo --build-arg TAG=$tag --build-arg VERSION=$version .
#build the progs image. depends on gobuild
docker build -t k3os/progs:$tag --file=images/progs.Dockerfile --build-arg ARCH=$arch --build-arg REPO=$repo --build-arg TAG=$tag --build-arg VERSION=$version .
#build the rootfs image. depends on base, progs, k3s
docker build -t k3os/rootfs:$tag --file=images/rootfs.Dockerfile --build-arg ARCH=$arch --build-arg REPO=$repo --build-arg TAG=$tag --build-arg VERSION=$version .
#build the bin image. depends on base, rootfs, progs
docker build -t k3os/bin:$tag --file=images/bin.Dockerfile --build-arg ARCH=$arch --build-arg REPO=$repo --build-arg TAG=$tag --build-arg VERSION=$version .
#build the kernel image. depends on bin, base
docker build -t k3os/kernel:$tag --file=images/kernel.Dockerfile --build-arg ARCH=$arch --build-arg REPO=$repo --build-arg TAG=$tag --build-arg VERSION=$version .
#build the package image. depends on base, bin, k3s, kernel
docker build -t k3os/package:$tag --file=images/package.Dockerfile --build-arg ARCH=$arch --build-arg REPO=$repo --build-arg TAG=$tag --build-arg VERSION=$version .
#build the iso image. depends on base, package
docker build -t k3os/iso:$tag --file=images/iso.Dockerfile --build-arg ARCH=$arch --build-arg REPO=$repo --build-arg TAG=$tag --build-arg VERSION=$version .

# nerdctl build -t k3os/kernel --file=images/k3os-kernel.Dockerfile .
# nerdctl build -t k3os/base --file=images/k3os-base.Dockerfile .
# nerdctl build -t k3os/gobuild --file=images/k3os-gobuild.Dockerfile .
