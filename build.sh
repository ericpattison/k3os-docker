#build the base image. depends on
docker build -t k3os/base:v0.0.0 --file=images/base.Dockerfile --build-arg ARCH=amd64 --build-arg REPO=k3os --build-arg TAG=v0.0.0 --build-arg VERSION=v1.23.3+k3s1 .
#build the gobuild image. depends on 
docker build -t k3os/gobuild:v0.0.0 --file=images/gobuild.Dockerfile --build-arg ARCH=amd64 --build-arg REPO=k3os --build-arg TAG=v0.0.0 --build-arg VERSION=v1.23.3+k3s1 .
#build the k3s image. depends on base
docker build -t k3os/k3s:v0.0.0 --file=images/k3s.Dockerfile --build-arg ARCH=amd64 --build-arg REPO=k3os --build-arg TAG=v0.0.0 --build-arg VERSION=v1.23.3+k3s1 .
#build the progs image. depends on gobuild
docker build -t k3os/progs:v0.0.0 --file=images/progs.Dockerfile --build-arg ARCH=amd64 --build-arg REPO=k3os --build-arg TAG=v0.0.0 --build-arg VERSION=v1.23.3+k3s1 .
#build the rootfs image. depends on base, progs, k3s
docker build -t k3os/rootfs:v0.0.0 --file=images/rootfs.Dockerfile --build-arg ARCH=amd64 --build-arg REPO=k3os --build-arg TAG=v0.0.0 --build-arg VERSION=v1.23.3+k3s1 .
#build the bin image. depends on base, rootfs, progs
docker build -t k3os/bin:v0.0.0 --file=images/bin.Dockerfile --build-arg ARCH=amd64 --build-arg REPO=k3os --build-arg TAG=v0.0.0 --build-arg VERSION=v1.23.3+k3s1 .
#build the kernel image. depends on bin, base
docker build -t k3os/kernel:v0.0.0 --file=images/kernel.Dockerfile --build-arg ARCH=amd64 --build-arg REPO=k3os --build-arg TAG=v0.0.0 --build-arg VERSION=v1.23.3+k3s1 .
#build the package image. depends on base, bin, k3s, kernel
docker build -t k3os/package:v0.0.0 --file=images/package.Dockerfile --build-arg ARCH=amd64 --build-arg REPO=k3os --build-arg TAG=v0.0.0 --build-arg VERSION=v1.23.3+k3s1 .
#build the iso image. depends on base, package
docker build -t k3os/iso:v0.0.0 --file=images/iso.Dockerfile --build-arg ARCH=amd64 --build-arg REPO=k3os --build-arg TAG=v0.0.0 --build-arg VERSION=v1.23.3+k3s1 .

# nerdctl build -t k3os/kernel --file=images/k3os-kernel.Dockerfile .
# nerdctl build -t k3os/base --file=images/k3os-base.Dockerfile .
# nerdctl build -t k3os/gobuild --file=images/k3os-gobuild.Dockerfile .