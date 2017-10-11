FROM ubuntu:16.04
MAINTAINER Joshua <joshua7v@hotmail.com>

ENV TERM xterm-256color

RUN apt-get update \
  && apt-get install -y openssh-server \
  software-properties-common \
  apt-transport-https \
  ca-certificates \
  locales \
  curl \
  wget \
  && curl -sL https://deb.nodesource.com/setup_8.x | bash -  \
  && wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && dpkg -i erlang-solutions_1.0_all.deb \
  && add-apt-repository ppa:neovim-ppa/stable \
  && apt-get update \
  && apt-get install -y \
  tmux \
  git \
  python3 \
  python3-pip \
  python3-dev \
  nodejs \
  esl-erlang \
  elixir \
  neovim \
  && mkdir /var/run/sshd \
  && sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config \
  && sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config \
  && echo 'root:root' |chpasswd \
  && locale-gen en_US.UTF-8 \
  && pip3 install neovim

RUN git clone https://github.com/joshua7v/dot-files ~/.dot-files \
  && cp ~/.dot-files/bashrc ~/.bashrc \
  && cp ~/.dot-files/bash_profile ~/.bash_profile \
  && mkdir -p ~/.config/nvim \
  && cp ~/.dot-files/neovim/init.vim ~/.config/nvim/init.vim \
  && curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > installer.sh \
  && bash ./installer.sh ~/.config/nvim \
  && rm installer.sh \
  && cp ~/.dot-files/tmux.conf ~/.tmux.conf \
  && curl -o- -L https://yarnpkg.com/install.sh | bash \
  && npm i -g --unsafe-perm=true --allow-root \
  typescript \
  create-react-app \
  @angular/cli \
  elm \
  elm-format \
  ctags \
  jsctags \
  prettier \
  serve

EXPOSE 22 3000
ENTRYPOINT ["/usr/sbin/sshd", "-D"]
VOLUME ["/data"]

