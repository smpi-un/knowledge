defmodule BookImporter do
  def main() do
    importz("test.txt")
  end
  def importz(file_path) do
    file = File.read(file_path)

    # テキストファイル内のISBNをすべて取得する
    isbns = Regex.scan(~r/\b[0-9]{13}\b/, file)

    # SQLite DB「books.db」のテーブル「books」の「ISBN」列を検索し、同じISBNが存在するものを除外する
    existing_isbns = query_existing_isbns()

    # 残ったISBNに対し、Google Books APIsから書籍情報を取得する
    book_infos = fetch_book_infos(isbns -- existing_isbns)

    # SQLite DB「books.db」のテーブル「books」に、取得した本の情報をいい感じに設定する
    insert_book_infos(book_infos)

    # ISBNをsuccess.logに追記出力する
    log_success_isbns(isbns -- existing_isbns)
  end

  def query_existing_isbns do
    # SQLite DB「books.db」に接続する
    # テーブル「books」が存在しない場合は作成する
    # テーブル「books」の「ISBN」列をすべて取得する
  end

  def fetch_book_infos(isbns) do
    # Google Books APIのアドレスを環境変数から取得する
    # 各ISBNに対して、Google Books APIを呼び出す
    # 取得失敗した場合は当該業に対する処理をスキップする
    # 取得した書籍情報のタイトル・著者(複数)・発行日をパースする
  end

  def insert_book_infos(book_infos) do
    # SQLite DB「books.db」に接続する
    # 各書籍情報に対して、テーブル「books」にレコードを挿入する
  end

  def log_success_isbns(isbns) do
    # success.logにISBNを追記出力する
  end
end
