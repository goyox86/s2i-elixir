
# s2i-elixir
FROM openshift/base-centos7

# TODO: Put the maintainer name in the image metadata
MAINTAINER Jose Narvaez <goyox86@gmail.com>

# TODO: Rename the builder environment variable to inform users about application you provide them
ENV BUILDER_VERSION 1.0

# TODO: Set labels used in OpenShift to describe the builder image
LABEL summary="Platform for building and running Elixir 1.3.3 applications" \
      io.k8s.description="Platform for building and running Elixir 1.3.3 applications" \
      io.k8s.display-name="Elixir 1.3.3" \
      io.openshift.expose-services="8080:http" \
io.openshift.tags="builder,elixir,elixir133,rh-elixir133"


# TODO: Install required packages here:
RUN yum install -y epel-release
RUN yum update -y && yum upgrade -y
RUN yum install -y gcc gcc-c++ glibc-devel make ncurses-devel openssl-devel autoconf java-1.8.0-openjdk-devel git
RUN yum install -y wxBase.x86_64
RUN yum install -y wget
RUN wget http://packages.erlang-solutions.com/erlang-solutions-1.0-1.noarch.rpm
RUN rpm -Uvh erlang-solutions-1.0-1.noarch.rpm
RUN yum install -y esl-erlang
RUN mkdir /opt/elixir
RUN git clone https://github.com/elixir-lang/elixir.git /opt/elixir
RUN localedef -c -f UTF-8 -i en_US en_US.UTF-8 && export LC_ALL=en_US.UTF-8 && cd /opt/elixir && git checkout v1.3.4 && make clean test
RUN ln -s /opt/elixir/bin/iex /usr/local/bin/iex
RUN ln -s /opt/elixir/bin/mix /usr/local/bin/mix
RUN ln -s /opt/elixir/bin/elixir /usr/local/bin/elixir
RUN ln -s /opt/elixir/bin/elixirc /usr/local/bin/elixirc
RUN yum clean all -y

# TODO (optional): Copy the builder files into /opt/app-root
# COPY ./<builder_folder>/ /opt/app-root/

# TODO: Copy the S2I scripts to /usr/libexec/s2i, since openshift/base-centos7 image sets io.openshift.s2i.scripts-url label that way, or update that label
COPY ./.s2i/bin/ /usr/libexec/s2i

# TODO: Drop the root user and make the content of /opt/app-root owned by user 1001
RUN chown -R 1001:1001 /opt/app-root

# This default user is created in the openshift/base-centos7 image
USER 1001

# TODO: Set the default port for applications built using this image
EXPOSE 8080

# TODO: Set the default CMD for the image
CMD ["iex"]
