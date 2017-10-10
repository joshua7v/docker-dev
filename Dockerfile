FROM alpine:3.6
MAINTAINER Joshua <joshua7v@hotmail.com>

RUN apk add --no-cache openssh \
  bash \
  tmux \
  neovim \
  git \
  curl \
  python3 \
  python3-dev \
  elixir \
  nodejs \
  nodejs-npm \
  alpine-sdk \
  && pip3 install neovim \
  && sed -i s/#PermitRootLogin.*/PermitRootLogin\ yes/ /etc/ssh/sshd_config \
  && echo "root:root" | chpasswd

RUN sed -i -e "s/bin\/ash/bin\/bash/" /etc/passwd
RUN git clone https://github.com/joshua7v/dot-files ~/.dot-files \
  && cp ~/.dot-files/bashrc ~/.bashrc \
  && cp ~/.dot-files/bash_profile ~/.bash_profile \
  && mkdir -p ~/.config/nvim \
  && cp ~/.dot-files/neovim/init.vim ~/.config/nvim/init.vim \
  && curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > installer.sh \
  && bash ./installer.sh ~/.config/nvim \
  && rm installer.sh \
  && cp ~/.dot-files/tmux.conf ~/.tmux.conf

RUN npm i -g typescript elm elm-format pm2 create-react-app @angular/cli yarn

ENV TERM xterm-256color

COPY entrypoint.sh /sbin
RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 22 3000
ENTRYPOINT ["/sbin/entrypoint.sh"]
VOLUME ["/data"]

