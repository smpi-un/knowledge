# Github Pages

ココ自体の使い方メモ

## 現状の``_config.yml``
```yml
plugins:
  - jekyll-sitemap
  - jekyll-remote-theme # add this line to the plugins list if you already have one

google_analytics: ここにGoogleAnaliticsのコード(G-xxxxxxxxx)を記載

remote_theme: pages-themes/architect@v0.2.0

title: [技術メモ]
description: [Umm...]

markdown: CommonMarkGhPages
commonmark:
  extensions:
    - autolink
    - strikethrough
    - table
```

## パーマリンク
できそうだけど試してない
https://jekyllrb-ja.github.io/docs/permalinks/


## TOC(目次)
http://www.seanbuscay.com/blog/jekyll-toc-markdown/
```md
* TOC
{:toc}
```

## サブドキュメントのリストアップ
TBD
## 左メニュー
TBD
## メタ情報
TBD

