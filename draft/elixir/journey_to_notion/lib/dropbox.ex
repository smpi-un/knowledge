defmodule DropboxUploader do
  @dropbox_api_url "https://content.dropboxapi.com/2/files/upload"
  @dropbox_token "TOKEN" # Dropboxのアクセストークンを設定

  # Dropboxに画像をアップロードする関数
  def upload_image_to_dropbox(local_file_path) do
    # ファイルの内容を読み込む
    file_content = File.read!(local_file_path)

    # HTTPヘッダーを設定
    headers = [
      {"Authorization", "Bearer #{@dropbox_token}"},
      {"Dropbox-API-Arg", "{\"path\": \"/images/#{Path.basename(local_file_path)}\",\"mode\": \"add\",\"autorename\": true,\"mute\": false,\"strict_conflict\": false}"},
      {"Content-Type", "application/octet-stream"}
    ]
    headers |> IO.inspect()
    file_content |> IO.inspect()

    # HTTPoisonを使用してHTTP POSTリクエストを送信
    HTTPoison.post(@dropbox_api_url, file_content, headers)
  end
end

Application.ensure_all_started(:httpoison)

# 使用例
path = "C:\\Users\\shimp\\OneDrive\\画像\\switch\\スーパーファミコン Nintendo Switch Online\\2022030621401600_c.jpg"
res = DropboxUploader.upload_image_to_dropbox(path)
res |> IO.inspect()
