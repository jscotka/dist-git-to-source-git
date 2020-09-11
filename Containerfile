# Copyright Contributors to the Packit project.
# SPDX-License-Identifier: MIT

ARG base_image=centos:8
ARG package_manager
FROM $base_image

ENV package_manager ${package_manager:-yum -y}
RUN $package_manager -y install gcc git krb5-devel python3-devel python3-pip rpm-build && $package_manager -y clean all
RUN curl --output /usr/bin/get_sources.sh https://git.centos.org/centos-git-common/raw/master/f/get_sources.sh && chmod +x /usr/bin/get_sources.sh
# Tools required by the %prep section of some packages
RUN $package_manager -y install \
    bison \
    flex \
    make \
    autoconf \
    automake \
    gettext-devel \
    sscg \
    libtool \
    && $package_manager -y clean all \
    && pip3 install ipdb pytest

RUN git config --system user.name "Packit" && git config --system user.email "packit"
COPY .git /src/.git
COPY dist2src /src/dist2src
COPY README.md setup.cfg setup.py /src/

WORKDIR /src
# TODO install dependencies from RPM, if possible
RUN pip3 install .

WORKDIR /workdir
VOLUME /workdir

COPY macros.packit /usr/lib/rpm/macros.d/macros.packit
COPY packitpatch /usr/bin/packitpatch

CMD ["dist2src"]
