FROM ubuntu:trusty
MAINTAINER ClassCat Co.,Ltd. <support@classcat.com>

########################################################################
# ClassCat/Bind9-CacheServer Dockerfile
#   Maintained by ClassCat Co.,Ltd ( http://www.classcat.com/ )
########################################################################

#--- HISTORY -----------------------------------------------------------
# 25-jun-15 : fixed.
#-----------------------------------------------------------------------

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get -y upgrade \
  && apt-get install -y language-pack-en language-pack-en-base \
  && apt-get install -y language-pack-ja language-pack-ja-base \
  && update-locale LANG="en_US.UTF-8" \
  && apt-get install -y openssh-server supervisor rsyslog \
  && apt-get install -y bind9 \
  && apt-get clean \
  && mkdir -p /var/run/sshd \
  && sed -ri "s/^PermitRootLogin\s+.*/PermitRootLogin yes/" /etc/ssh/sshd_config
# RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

COPY assets/supervisord.conf /etc/supervisor/supervisord.conf
COPY assets/named.conf.options /etc/bind/named.conf.options

WORKDIR /opt
ADD assets/cc-init.sh /opt/cc-init.sh

EXPOSE 22 53

CMD /opt/cc-init.sh; /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
