FROM --platform=linux/amd64 registry.fedoraproject.org/fedora-minimal:rawhide

MAINTAINER Daiki Ueno <ueno@gnu.org>

ARG dnfflags="--setopt install_weak_deps=False"

RUN dnf -y update
RUN dnf -y install 'dnf5-command(builddep)'
RUN dnf -y builddep libskk
RUN dnf install $dnfflags -y git libtool make which gcc-c++ libxkbcommon-devel glibc-gconv-extra libasan libubsan python-pip gtk-doc vala vala-devel valadoc valadoc-devel
RUN dnf clean all

RUN groupadd -g 10000 user
RUN useradd -g user -m -u 10000 user
