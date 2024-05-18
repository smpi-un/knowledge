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
引数で指定したパスのファイルを開き、上から順に次の処理を繰り返し実行する。
開いたファイルには改行区切りでISBNが記載されていることを想定している。
1. n桁かつすべて数字であることをチェックする。条件を満たさない場合は当該行に対する処理をスキップする。
2. Google Books APIsから書籍情報を取得する。取得失敗した場合は当該業に対する処理をスキップする。
   なお、Google Books APIのアドレスは環境変数から取得する。
3. 取得した書籍情報のタイトル・著者(複数)・発行日を標準出力する。ただし、発行日は「yyyy年mm月dd日(曜日)」のフォーマットとする。
4. ISBNをsuccess.logに追記出力する

確認しいこと
- プログラムへの引数処理
- テキストファイルオープン
- HTTPリクエスト
- Json処理
- 標準出力
- テキストファイル出力



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