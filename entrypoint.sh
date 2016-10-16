#!/bin/bash

USERNAME=${USERNAME:-joshua}
PASSWORD=${PASSWORD:-pwd}

useradd -s /bin/bash -d /home/$USERNAME -m $USERNAME
echo "$USERNAME:$PASSWORD" | chpasswd

mv /etc/sudoers /etc/sudoers.bak
cat /etc/sudoers.bak ; echo "$USERNAME ALL=(ALL) ALL" > /etc/sudoers

/usr/sbin/sshd -D
