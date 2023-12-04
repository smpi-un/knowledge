# 環境構築関係


## nim

dockerで構築すれば楽。

docker-compose.yml
```yml
version: "3.9"

services:
  app:
    container_name: "app"
    build: "."
    env_file:
      - .env
    volumes:
      # - ./api/app:/app
    # ports:
    #   - 5000:5000
    # stdin_open: true
    # tty: true
    # # command:
    #   # echo "hello"
    # networks:
    #   - backend
    # depends_on:
      # - db
```

Dockerfile
```dockerfile
FROM nimlang/choosenim

RUN choosenim stable
# RUN choosenim 1.6.14
# RUN choosenim devel
WORKDIR /app

# update nimble
RUN nimble install -y nimble

# install external tools
RUN apt update

```
