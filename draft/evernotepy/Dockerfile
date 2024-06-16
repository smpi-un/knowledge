# ベースイメージとしてPython 2.7のイメージを使用
FROM python:2.7-slim

# 作業ディレクトリを設定
WORKDIR /usr/src/app

# 必要なシステムパッケージをインストール
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    libssl-dev \
    libffi-dev \
    python-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y ca-certificates
RUN update-ca-certificates

# Pythonの依存パッケージをrequirements.txtからインストール
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY evernote-sdk-python/sample/django/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install certifi


# アプリケーションのソースコードをコピー
COPY . .

# 作業ディレクトリを設定
WORKDIR /usr/src/app/evernote-sdk-python/sample/django
# コンテナ起動時に実行するコマンド
# CMD ["python", "./main.py"]
# CMD ["python", "evernote-sdk-python/sample/django/manage.py", "runserver"]
# CMD ["python", "evernote-sdk-python/sample/django/manage.py", "runserver", "0.0.0.0:8000"]
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
