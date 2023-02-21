FROM registry.access.redhat.com/ubi8/go-toolset:1.17.7 as builder

USER root
WORKDIR /workspace
COPY . .
RUN make build_podman_e2e

FROM registry.access.redhat.com/ubi8/ubi-minimal 

LABEL org.opencontainers.image.authors="CodeReady Containers <devtools-cdk@redhat.com>"

COPY --from=builder /workspace/images/build-podman-e2e/entrypoint.sh /usr/local/bin/
COPY --from=builder /workspace/out /opt/crc/bin

ENV EPEL https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

RUN rpm -ivh ${EPEL} \ 
    && microdnf --enablerepo=epel install -y openssh-clients sshpass \
    && microdnf clean all

ENTRYPOINT ["entrypoint.sh"]
