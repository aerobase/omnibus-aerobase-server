FROM ubuntu:20.04
MAINTAINER Aerobase LTD. <support@aerobase.io>

SHELL ["/bin/sh", "-c"],

# Default to supporting utf-8
ENV LANG=C.UTF-8

# Install required packages
RUN apt-get update -q \
    && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
      ca-certificates \
      openssh-server \
      openjdk-17-jre \
      wget \
      apt-transport-https \
      vim \
      tzdata \
      nano \
      curl \
      locales \
      net-tools \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && sed 's/session\s*required\s*pam_loginuid.so/session optional pam_loginuid.so/g' -i /etc/pam.d/sshd

# Set local for PostgreSQL instance
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

# Remove MOTD
RUN rm -rf /etc/update-motd.d /etc/motd /etc/motd.dynamic
RUN ln -fs /dev/null /run/motd.dynamic

# Copy assets
COPY assets/ /assets
RUN /assets/download
RUN /assets/setup

# Allow to access embedded tools
ENV PATH /opt/aerobase/embedded/bin:/opt/aerobase/bin:/assets:$PATH

# Resolve error: TERM environment variable not set.
ENV TERM xterm

# Expose web & ssh
EXPOSE 443 80 22

# Define data volumes
VOLUME ["/etc/aerobase", "/var/opt/aerobase", "/var/log/aerobase", "/etc/init"]

RUN cd /opt/aerobase/embedded/lib/ruby
RUN gem install rack -v 2.2.3.1
RUN gem uninstall rack -v 2.2.3

# Wrapper to handle signal, trigger runit and reconfigure Aerobase
CMD ["/assets/wrapper"]
