
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