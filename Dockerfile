FROM ubuntu:16.04
MAINTAINER Joshua <joshua7v@hotmail.com>

ENV TERM xterm-256color
ENV GIT_USER_NAME joshua7v
ENV GIT_USER_EMAIL joshua7v@hotmail.com
ENV TZ Aisa/Shanghai
ENV TMUX_VERSION 2.6
ENV HOME /root
ENV GOLANG_VERSION 1.9.1
ENV GOPATH $HOME/.go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN apt-get update \
  && apt-get install -y openssh-server \
  software-properties-common \
  apt-transport-https \
  ca-certificates \
  locales \
  tzdata \
  curl \
  wget \
  && curl -sL https://deb.nodesource.com/setup_8.x | bash -  \
  && wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && dpkg -i erlang-solutions_1.0_all.deb \
  && add-apt-repository ppa:neovim-ppa/stable \
  && apt-get update \
  && apt-get install -y \
  man \
  iputils-ping \
  net-tools \
  iftop \
  iotop \
  git \
  python3 \
  python3-pip \
  python3-dev \
  nodejs \
  esl-erlang \
  elixir \
  vim \
  htop \
  neovim \
  ctags \
  silversearcher-ag \
  unzip \
  inotify-tools \
  tree \
  libevent-dev \
  ncurses-dev \
  zsh \
  && mkdir /var/run/sshd \
  && sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config \
  && sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config \
  && echo 'root:root' |chpasswd \
  && locale-gen en_US.UTF-8 \
  && pip3 install neovim \
  && cd ~ \

  # Install rclone
  && curl -O https://downloads.rclone.org/rclone-current-linux-amd64.zip \
  && unzip rclone-current-linux-amd64.zip \
  && cd rclone-*-linux-amd64 \
  && cp rclone /usr/bin/ \
  && mkdir -p /usr/local/share/man/man1 \
  && cp rclone.1 /usr/local/share/man/man1/ \
  && mandb \
  && cd ~ \
  && rm -fr rclone* \

  # Install tmux
  && wget https://github.com/tmux/tmux/releases/download/$TMUX_VERSION/tmux-$TMUX_VERSION.tar.gz \
  && tar -zxf tmux-$TMUX_VERSION.tar.gz \
  && cd tmux-$TMUX_VERSION \
  && ./configure && make \
  && mv tmux /usr/bin/tmux \
  && cd ~ \
  && rm -fr tmux-$TMUX_VERSION* \

  # Install go
  && wget https://storage.googleapis.com/golang/go$GOLANG_VERSION.linux-amd64.tar.gz \
  && tar -C /usr/local -xzf go$GOLANG_VERSION.linux-amd64.tar.gz \
  && cd ~ \
  && rm -fr go$GOLANG_VERSION* \

  # Change to zsh
  && chsh -s $(which zsh) \
  && apt-get clean

RUN curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | bash \
  && git clone git://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions \

  # Fix time zone
  && echo $TZ > /etc/timezone \
  && rm /etc/localtime \
  && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
  && dpkg-reconfigure -f noninteractive tzdata \
  && apt-get clean \

  # Set default git user
  && git config --global user.name $GIT_USER_NAME \
  && git config --global user.email $GIT_USER_EMAIL \

  # Set git differ
  && curl -O https://raw.githubusercontent.com/so-fancy/diff-so-fancy/master/third_party/build_fatpack/diff-so-fancy \
  && chmod +x diff-so-fancy \
  && mv diff-so-fancy /usr/local/bin/diff-so-fancy \
  && git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX" \
  && git config --global color.ui true \
  && git config --global color.diff-highlight.oldNormal "red bold" \
  && git config --global color.diff-highlight.oldHighlight "red bold 52" \
  && git config --global color.diff-highlight.newNormal "green bold" \
  && git config --global color.diff-highlight.newHighlight "green bold 22" \
  && git config --global color.diff.meta "227" \
  && git config --global color.diff.frag "magenta bold" \
  && git config --global color.diff.commit "227 bold" \
  && git config --global color.diff.old "red bold" \
  && git config --global color.diff.new "green bold" \
  && git config --global color.diff.whitespace "red reverse" \

  # Restore shell settings
  && git clone https://github.com/joshua7v/dot-files ~/.dot-files \
  && cp ~/.dot-files/bashrc ~/.bashrc \
  && cp ~/.dot-files/bash_profile ~/.bash_profile \
  && cp ~/.dot-files/zshrc ~/.zshrc \

  # Restore neovim settings
  && mkdir -p ~/.config/nvim \
  && cp ~/.dot-files/neovim/init.vim ~/.config/nvim/init.vim \
  && curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > installer.sh \
  && bash ./installer.sh ~/.config/nvim \
  && rm installer.sh \
  && sed -i "/filetype\ plugin\ indent\ on/ilet g:dein#install_progress_type = 'none'\nlet g:dein#install_message_type = 'none'\n" ~/.config/nvim/init.vim \
  && sed -i "/'build':\ 'make'/d" ~/.config/nvim/init.vim \
  && nvim +"call dein#install()" +qall \
  && cd ~/.config/nvim/plugged/repos/github.com/zchee/deoplete-go/rplugin/python3/deoplete/ujson/ \
  && python3 setup.py build --build-base=/root/.config/nvim/plugged/repos/github.com/zchee/deoplete-go/build --build-lib=/root/.config/nvim/plugged/repos/github.com/zchee/deoplete-go/build \
  && cd ~ \
  && cp ~/.dot-files/neovim/init.vim ~/.config/nvim/init.vim \

  # Restore tmux settings
  && cp ~/.dot-files/tmux.conf ~/.tmux.conf \
  && git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm \
  && ~/.tmux/plugins/tpm/bin/install_plugins \

  # Install elixir packages
  && mix local.hex --force \
  && mix local.rebar --force \
  && mix archive.install https://github.com/phoenixframework/archives/raw/master/phx_new.ez --force \
  && git clone https://github.com/lpil/dogma \
  && cd dogma \
  && mix deps.get \
  && mix escript.build \
  && cp dogma /usr/local/bin/dogma \
  && cd .. \
  && rm -fr dogma \

  # Install go packages
  && echo 'export GOPATH=$HOME/.go' >> .bashrc \
  && echo 'export PATH=$GOPATH/bin:/usr/local/go/bin:$PATH' >> .bashrc \
  && go get -u github.com/nsf/gocode \

  # Install python packages
  && pip3 install --upgrade pip \
  && pip3 install pgcli \

  # Install js / ts / elm packages
  && curl -o- -L https://yarnpkg.com/install.sh | bash \
  && npm i -g --unsafe-perm=true --allow-root \
  typescript \
  create-react-app \
  create-elm-app \
  @angular/cli \
  elm \
  elm-format \
  elm-live \
  eslint \
  tslint \
  jsctags \
  prettier \
  serve

EXPOSE 22 3000
ENTRYPOINT ["/usr/sbin/sshd", "-D"]
VOLUME ["/data"]

