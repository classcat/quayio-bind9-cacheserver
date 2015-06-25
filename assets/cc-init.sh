#!/bin/bash

########################################################################
# ClassCat/bind9-cacheserver Asset files
# Copyright (C) 2015 ClassCat Co.,Ltd. All rights reserved.
########################################################################

#--- HISTORY -----------------------------------------------------------
# 25-jun-15 : fixed.
#-----------------------------------------------------------------------


######################
### INITIALIZATION ###
######################

function init () {
  echo "ClassCat Info >> initialization code for ClassCat/Bind9-CacheServer"
  echo "Copyright (C) 2015 ClassCat Co.,Ltd. All rights reserved."
  echo ""
}


############
### SSHD ###
############

function change_root_password() {
  if [ -z "${ROOT_PASSWORD}" ]; then
    echo "ClassCat Warning >> No ROOT_PASSWORD specified."
  else
    echo -e "root:${ROOT_PASSWORD}" | chpasswd
    # echo -e "${password}\n${password}" | passwd root
  fi
}


function put_public_key() {
  if [ -z "$SSH_PUBLIC_KEY" ]; then
    echo "ClassCat Warning >> No SSH_PUBLIC_KEY specified."
  else
    mkdir -p /root/.ssh
    chmod 0700 /root/.ssh
    echo "${SSH_PUBLIC_KEY}" > /root/.ssh/authorized_keys
  fi
}


#############
### BIND9 ###
#############

function config_named_conf_options {
  # allow-recursion { 127.0.0.1; };

  sed -i.bak -e "s/^\s*allow-recursion.*$/\tallow-recursion { $ALLOW_RECURSION }/" /etc/bind/named.conf.options
}


##################
### SUPERVISOR ###
##################
# See http://docs.docker.com/articles/using_supervisord/

function proc_supervisor () {
  if [ -e /etc/supervisor/conf.d/supervisord.conf ]; then
    echo "ClassCat Warning >> /etc/supervisor/conf.d/supervisord.conf found, then skip configuration."
    return
  fi

  cat > /etc/supervisor/conf.d/supervisord.conf <<EOF
[program:ssh]
command=/usr/sbin/sshd -D

[program:bind9]
command=service bind9 restart

[program:rsyslog]
command=/usr/sbin/rsyslogd -n
EOF
}


### ENTRY POINT ###

init
change_root_password
put_public_key
config_named_conf_options
proc_supervisor

# /usr/bin/supervisord -c /etc/supervisor/supervisord.conf

exit 0


### End of Script ###
