FROM joshua7v/sshd
MAINTAINER Joshua <joshua7v@hotmail.com>

RUN apt-get update && apt-get install -y \ 
    vim python python-dev python-pip python-virtualenv python3 \
    curl git build-essential nodejs-legacy npm cmake tmux weechat
RUN npm i -g npm@latest

ENV TERM xterm-256color

RUN curl -o- https://raw.githubusercontent.com/joshua7v/vim/master/install.sh | bash
RUN curl -o- https://raw.githubusercontent.com/joshua7v/vim/master/install-optional.sh | bash
RUN curl -o- https://raw.githubusercontent.com/joshua7v/dot-files/master/install.sh | bash

ADD entrypoint.sh /sbin
RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 22 80
ENTRYPOINT ["/sbin/entrypoint.sh"]
VOLUME ["/root/erinn"]
