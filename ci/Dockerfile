FROM --platform=linux/amd64 registry.fedoraproject.org/fedora-minimal:43

MAINTAINER Daiki Ueno <ueno@gnu.org>

ARG dnfflags="--setopt install_weak_deps=False"

RUN dnf -y update
RUN dnf -y install 'dnf5-command(builddep)'
RUN dnf -y builddep libskk
RUN dnf install $dnfflags -y libtool make which gcc-c++ vala vala-devel git libxkbcommon-devel glibc-gconv-extra libasan libubsan python-pip gtk-doc fedora-repos-rawhide
# valadoc in F43 has known segfaults, pull in the working version from rawhide
RUN dnf install $dnfflags --enablerepo=rawhide -y valadoc valadoc-devel
RUN dnf clean all

RUN groupadd -g 10000 user
RUN useradd -g user -m -u 10000 user
