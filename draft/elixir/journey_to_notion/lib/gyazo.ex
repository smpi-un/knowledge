defmodule GyazoUploader do
  @moduledoc """
  A module to upload images to Gyazo, return their URLs, and delete them.
  """

  Application.ensure_all_started(:dotenv)
  Dotenv.load()
  @access_token System.get_env("GYAZO_ACCESS_TOKEN")
  @gyazo_upload_url "https://upload.gyazo.com/api/upload"
  @gyazo_delete_url "https://api.gyazo.com/api/images/"

  def upload_file(file_path) do
    headers = [
      {"Authorization", "Bearer #{@access_token}"}
    ]

    body = {:multipart, [
      {"imagedata", File.read!(file_path), {"form-data", [{"name", "imagedata"}, {"filename", Path.basename(file_path)}]}, []}
    ]}

    case HTTPoison.post(@gyazo_upload_url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, response} = Jason.decode(body)
        {:ok, response["url"], response["image_id"]}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  def delete_file(image_id) do
    headers = [
      {"Authorization", "Bearer #{@access_token}"}
    ]

    url = "#{@gyazo_delete_url}#{image_id}"

    case HTTPoison.delete(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, response} = Jason.decode(body)
        {:ok, response}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

end

# 呼び出し元関数の例
defmodule GyazoExample do
  def run_example do
    input_path = "/home/smpiun/Documents/Journey/journey-1682595279118_DL/1681642386485-3fea9157b297f3ce-3fd84fcd19f24294.webp"
    # upload_and_delete(input_path)
    GyazoUploader.delete_file("35ac9ca9e8064b2fa2598b7b8c2ef270")
  end
  def upload_and_delete(file_path) do
    case GyazoUploader.upload_file(file_path) do
      {:ok, url, image_id} ->
        IO.puts("Uploaded #{image_id} image URL: #{url}")

      {:error, reason} ->
        IO.puts("Failed to upload image: #{reason}")
    end
  end
end

# 実行例
if false do
  Application.ensure_all_started(:porcelain)
  Application.ensure_all_started(:httpoison)
  GyazoExample.run_example()
end
