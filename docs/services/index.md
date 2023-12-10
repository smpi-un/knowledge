
## FESS
https://fess.codelibs.org/ja/setup.html

```
curl -o compose.yaml https://raw.githubusercontent.com/codelibs/docker-fess/master/compose/compose.yaml
curl -o compose-opensearch2.yaml https://raw.githubusercontent.com/codelibs/docker-fess/master/compose/compose-opensearch2.yaml
```


Fessの起動
Fessをdocker composeコマンドで起動します。

コマンドプロンプトを開き、compose.yamlファイルがあるフォルダーに移動して、以下のコマンドを実行します。

```
docker compose -f compose.yaml -f compose-opensearch2.yaml up -d
```
初期パスワード
admin / admin


### compose.yml
volumesを追加。
```yml
services:
  fess01:
    image: ghcr.io/codelibs/fess:14.11.0
    # build: ./playwright # use Playwright
    container_name: fess01
    environment:
      - "SEARCH_ENGINE_HTTP_URL=http://es01:9200"
      - "FESS_DICTIONARY_PATH=${FESS_DICTIONARY_PATH:-/usr/share/opensearch/config/dictionary/}"
      # - "FESS_PLUGINS=fess-webapp-semantic-search:14.11.0 fess-ds-wikipedia:14.11.0"
    ports:
      - "8080:8080"
    networks:
      - esnet
    depends_on:
      - es01
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "5"
    restart: unless-stopped

    volumes:
      - ~/Documents:/var/www
      # - ~/:/data


networks:
  esnet:
    driver: bridge

```

---
https://discuss.codelibs.org/t/fess-14-7-localhost-8080-404-not-found/2146/3

> sudo sysctl -w vm.max_map_count=262144


## iroha Board

https://qiita.com/tksarah/items/575c144c12499c0c7ec8


## Open Project
https://www.openproject.org/docs/installation-and-operations/installation/docker/

```
git clone https://github.com/opf/openproject-deploy --depth=1 --branch=stable/13 openproject

cd openproject/compose

docker compose pull

OPENPROJECT_HTTPS=false docker compose up -d
```
初期パスワードは admin/admin
## Moodle
https://github.com/bitnami/containers/blob/main/bitnami/moodle/docker-compose.yml
```yml
# Copyright VMware, Inc.
# SPDX-License-Identifier: APACHE-2.0

version: '2'
services:
  mariadb:
    image: docker.io/bitnami/mariadb:11.1
    environment:
      # ALLOW_EMPTY_PASSWORD is recommended only for development.
      - ALLOW_EMPTY_PASSWORD=yes
      - MARIADB_USER=bn_moodle
      - MARIADB_DATABASE=bitnami_moodle
      - MARIADB_CHARACTER_SET=utf8mb4
      - MARIADB_COLLATE=utf8mb4_unicode_ci
    volumes:
      - 'mariadb_data:/bitnami/mariadb'
  moodle:
    image: docker.io/bitnami/moodle:4.3
    ports:
      - '80:8080'
      - '443:8443'
    environment:
      - MOODLE_DATABASE_HOST=mariadb
      - MOODLE_DATABASE_PORT_NUMBER=3306
      - MOODLE_DATABASE_USER=bn_moodle
      - MOODLE_DATABASE_NAME=bitnami_moodle
      # ALLOW_EMPTY_PASSWORD is recommended only for development.
      - ALLOW_EMPTY_PASSWORD=yes
    volumes:
      - 'moodle_data:/bitnami/moodle'
      - 'moodledata_data:/bitnami/moodledata'
    depends_on:
      - mariadb
volumes:
  mariadb_data:
    driver: local
  moodle_data:
    driver: local
  moodledata_data:
    driver: local
```

docker-compose.yml
```yml
version: '2'
services:
  moodle_mariadb:
    image: 'docker.io/bitnami/mariadb:10.3-debian-10'
    environment:
      - ALLOW_EMPTY_PASSWORD=yes
      - MARIADB_USER=bn_moodle
      - MARIADB_DATABASE=bitnami_moodle
    volumes:
      - 'moodle_mariadb_data:/bitnami/mariadb'
  moodle:
    image: 'docker.io/bitnami/moodle:3.9.1-debian-10-r14'
    ports:
      - '8084:8080'
      - '8444:8443'
    environment:
      - MOODLE_DATABASE_HOST=moodle_mariadb
      - MOODLE_DATABASE_PORT_NUMBER=3306
      - MOODLE_DATABASE_USER=bn_moodle
      - MOODLE_DATABASE_NAME=bitnami_moodle
      - ALLOW_EMPTY_PASSWORD=yes
    volumes:
      - 'moodle_data:/bitnami/moodle'
      - 'moodledata_data:/bitnami/moodledata'
    depends_on:
      - moodle_mariadb
volumes:
  moodle_mariadb_data:
    driver: local
  moodle_data:
    driver: local
  moodledata_data:
    driver: local

```

### 初期パスワード
https://mebee.info/2021/05/07/post-33655/
user / bitnami でログイン

## Activiti

https://activiti.gitbook.io/activiti-7-developers-guide/getting-started/getting-started-activiti-cloud/getting-started-docker-compose

```sh
git clone https://github.com/Activiti/activiti-cloud-examples
cd activiti-cloud-examples/docker-compose
```
makeが入っていなければ入れて、modeler起動。
```sh
apt install make -y
make modeler
```
ただし、Makefileを書き換え。
```
COMPOSE := docker compose
```

初期ID/パスワード
modeler/password

モデラーは起動できた。で、これ回すのどうするの？UIは別途用意しなきゃならない？

https://at-sushi.com/pukiwiki/pukiwiki.php?Java%20Activiti%20Explorer
http://labo-blog.aegif.jp/2013/07/activiti-bpm-platform2activiti-explorer.html
```sh
```

## Exment
[https://exment.net/docs/#/ja/install_docker]
```sh
git clone https://github.com/exment-git/docker-exment.git
cd docker-exment/build/php81_mariadb
# docker compose -f docker-compose.yml up
docker compose -f docker-compose.mariadb.yml -f docker-compose.yml up
```

公式うまくいかない。

以下
https://zenn.dev/avot/articles/f657f8ec709df6

docker-compose.yml
```yml
version: '3'
services:
  nginx:
    image: nginx:latest
    ports:
      - 8080:80
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/conf.d/default.conf
      - www-data:/var/www
    depends_on:
      - php

  php:
    build: ./php
    volumes:
      - www-data:/var/www
    depends_on:
      - db

  db:
    image: mysql:5.7
    ports:
      - 13306:3306
    volumes:
      - mysql-data:/var/lib/mysql
    environment:
      MYSQL_DATABASE: exment_database
      MYSQL_ROOT_PASSWORD: secret
      MYSQL_USER: exment_user
      MYSQL_PASSWORD: secret

#  phpmyadmin:
#    image: phpmyadmin/phpmyadmin:latest
#    ports:
#      - 8888:80
#    depends_on:
#      - db

# volumes を定義する
volumes:
  # volume の名前を指定
  # Exmentのインストールパス
  www-data:
    # Compose の外ですでに作成済みの volume を指定する場合は ture を設定する。
    # そうすると、 docker-compose up 時に Compose は volume を作成しようとしません。
    # かつ、指定した volume が存在しないとエラーを raise します。
    # external: true
  # mysql dbのインストールパス
  mysql-data:
  # external: true

```
php/Dockerfile

```
FROM php:8.0-fpm

# install php-ext
RUN apt-get update && apt-get install -y \
  git vim libonig-dev libzip-dev unzip libxml2-dev libpng-dev default-mysql-client \
  && docker-php-ext-install mbstring mysqli dom gd zip pdo_mysql \
  && apt-get clean
~~~
```

わかるません。  

## GroupSession

docker-compose.yml
```yml
version: '3'

services:
  tomcat:
    container_name: my-gsession-test
    build: ./tomcat9
    ports:
    - "8080:8080"
    volumes:
    - ./webapps:/usr/local/tomcat/webapps
```

Dockerfile
```dockerfile
FROM tomcat:9.0.58
ADD OpenJDK11U-jdk_x64_linux_hotspot_11.0.15_10.tar.gz /usr/local/java

ENV JAVA_HOME="/usr/local/java/jdk-11.0.15+10"
ENV PATH="$JAVA_HOME/bin:$PATH"

```


## SHIRASAGI
https://github.com/shin73/shirasagi-docker


```
git clone git@github.com:shin73/shirasagi-docker.git
cd shirasagi-docker
git clone git@github.com:shirasagi/shirasagi.git
docker compose up -d
```