---
title: "新興言語 比較メモ" # 記事のタイトル
emoji: "🧩" # アイキャッチとして使われる絵文字（1文字だけ）
type: "tech" # tech: 技術記事 / idea: アイデア記事
topics: ["pattern matching", "python", "nim"] # タグ。["markdown", "rust", "aws"]のように指定する
published: false # 公開設定（falseにすると下書き）
---

# 新興言語 比較メモ

https://www.googleapis.com/books/v1/volumes?q=isbn:4774176982

## サンプルデータ
1. 引数で指定したパスのファイルを開く。
   開いたファイルにはISBNを含む文章が記載されていることを想定している。
2. テキストファイル内のISBNをすべて取得する。
3. SQLite DB「books.db」のテーブル「books」の「ISBN」列を検索し、同じISBNが存在するものを除外する。
   ただし、「books.db」およびテーブル「books」がが存在しない場合は作成する。テーブル情報は以下の通り。
   - ID: UUIDv4を割り振る
   - ISBN: 本のISBN情報
   - Title: 本の題目
4. 残ったISBNに対し、Google Books APIsから書籍情報を取得する。取得失敗した場合は当該業に対する処理をスキップする。
   なお、Google Books APIのアドレスは環境変数から取得する。
5. 取得した書籍情報のタイトル・著者(複数)・発行日を標準出力する。ただし、発行日は「yyyy年mm月dd日(曜日)」のフォーマットとする。
6. SQLite DB「books.db」のテーブル「books」に、取得した本の情報をいい感じに設定する。
7. ISBNをsuccess.logに追記出力する

確認しいこと
- プログラムへの引数処理
- テキストファイルオープン
- HTTPリクエスト
- Json処理
- 標準出力
- テキストファイル出力
- SQLiteの処理


| 言語名 | 引数処理 |テキストファイル処理| HTTPリクエスト | Json処理 | テキストファイル出力 | SQLiteからの読み込み、書き込み |
|---|---|-|
|   |   | |


## コードの比較

### Roc
### Gleam
### Nim
```nim
```

### Dart
```dart
```

---
そのうち作る
### Haxe
```haxe
```
### Elixir
```elixir
```
## 諦めたもの
### koka
ライブラリ不足で。
HTTPリクエストやjson処理を1から作るのは。。。