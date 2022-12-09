ARG TAG
FROM k3os/gobuild:${TAG}

ENV LINUXKIT=v0.8

FROM k3os/gobuild:${TAG} as linuxkit
ENV GO111MODULE off
RUN git clone https://github.com/linuxkit/linuxkit.git $GOPATH/src/github.com/linuxkit/linuxkit
WORKDIR $GOPATH/src/github.com/linuxkit/linuxkit/pkg/metadata
RUN git checkout -b current $LINUXKIT
RUN /usr/bin/gobuild -o /output/metadata

FROM k3os/gobuild:${TAG} as k3os
ARG VERSION
COPY go-src/go.mod $GOPATH/src/github.com/rancher/k3os/
COPY go-src/go.sum $GOPATH/src/github.com/rancher/k3os/
COPY /pkg/ $GOPATH/src/github.com/rancher/k3os/pkg/
COPY go-src/main.go $GOPATH/src/github.com/rancher/k3os/
COPY go-src/vendor/ $GOPATH/src/github.com/rancher/k3os/vendor/
WORKDIR $GOPATH/src/github.com/rancher/k3os
RUN /usr/bin/gobuild -mod=readonly -o /output/k3os

FROM k3os/gobuild:${TAG}
COPY --from=linuxkit /output/ /output/
COPY --from=k3os /output/ /output/
WORKDIR /output
RUN git clone --branch v0.7.0 https://github.com/ahmetb/kubectx.git \
 && chmod -v +x kubectx/kubectx kubectx/kubens