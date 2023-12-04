
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