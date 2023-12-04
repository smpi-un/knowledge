# 技術メモ

* TOC
{:toc}

- [ ] FESS(ラズパイ？)
- [ ] Canvas LMS
- [ ] Open Project
## 気になるもの

https://book.mynavi.jp/manatee/about/
https://qiita.com/nyanko-box/items/52aace19cb99fb1146c2

- グループウェア
  - SHIRASAGI
  - GroupSession
  - Zimbra
- プロジェクト
  - Open Project
- CMS
  - iroha Board
    https://irohaboard.irohasoft.jp/download/

[文字起こし](文字起こし.ipynb)

- [services](./services/)
- [githubpage](./githubpage)
- [env](./env)
- [python](./python/)


Dockerfile
```Dockerfile
FROM php:7.4-apache

# 必要なモジュールのインストール
RUN apt-get update && \
    apt-get install -y \
    zlib1g-dev \
    libzip-dev \
    unzip \
    mariadb-client && \
    docker-php-ext-install pdo_mysql zip

# Apache の設定
RUN a2enmod rewrite

# ソースコードのダウンロードと展開
ADD https://github.com/your_repo/iroha_board/archive/master.zip /var/www/html/
WORKDIR /var/www/html/
RUN unzip master.zip && rm master.zip
RUN mv iroha_board-master/* . && rm -r iroha_board-master

# アクセス権限の設定
RUN chown -R www-data:www-data /var/www/html

# Apache の設定ファイル
COPY ./000-default.conf /etc/apache2/sites-enabled

# PHP PDO接続エラー対応
RUN echo "date.timezone = Asia/Tokyo" > /usr/local/etc/php/conf.d/timezone.ini



```
docker-compose.yml
```yml
version: '3'
services:
  web:
    build: .
    volumes:
      - ./app:/var/www/html/app
    ports:
      - '80:80'
    links:
      - db
  db:
    image: mysql:8.0
    command: --default-authentication-plugin=mysql_native_password
    volumes:
      - db_data:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: irohaboard
      MYSQL_USER: root
      MYSQL_PASSWORD: 

volumes:
  db_data:
```