FROM debian:bullseye-slim

RUN apt-get update \
    && apt-get install -y curl build-essential git \
    && rm -rf /var/lib/apt/lists/*

# choosenimのインストール
RUN curl https://nim-lang.org/choosenim/init.sh -sSf | sh
ENV PATH /root/.nimble/bin:$PATH

# Nimのインストールディレクトリを作成
RUN mkdir /usr/local/nim

# choosenimのインストール先を指定
ENV CHOOSENIM_INSTALL_DIR /usr/local/nim