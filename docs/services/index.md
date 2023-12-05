
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


## compose.yml
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