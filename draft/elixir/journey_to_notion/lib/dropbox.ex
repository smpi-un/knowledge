defmodule DropboxUploader do
  @moduledoc """
  A module for uploading files to Dropbox and obtaining a temporary link.
  """

  Application.ensure_all_started(:httpoison)
  Application.ensure_all_started(:dotenv)
  Dotenv.load()
  @client_id System.get_env("DROPBOX_APP_KEY")
  @client_secret System.get_env("DROPBOX_APP_SECRET")
  @refresh_token System.get_env("DROPBOX_REFRESH_TOKEN")
  @token_url "https://api.dropbox.com/oauth2/token"
  @upload_url "https://content.dropboxapi.com/2/files/upload"
  @temporary_link_url "https://api.dropboxapi.com/2/files/get_temporary_link"
  @delete_url "https://api.dropboxapi.com/2/files/delete_v2"


  def get_access_token do
    "get_access_token" |> IO.inspect()
    headers = [{"Content-Type", "application/x-www-form-urlencoded"}]
    body = URI.encode_query(%{
      "grant_type" => "refresh_token",
      "refresh_token" => @refresh_token,
      "client_id" => @client_id,
      "client_secret" => @client_secret
    })

    case HTTPoison.post(@token_url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        %{"access_token" => access_token} = Jason.decode!(body)
        {:ok, access_token}

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        IO.puts("Failed to get access token: #{status_code}")
        {:error, Jason.decode!(body)}

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts("Error: #{reason}")
        {:error, reason}
    end
  end

  def upload_file(access_token, local_path, dropbox_path) do
    "upload_file" |> IO.inspect()
    file_content = File.read!(local_path)

    headers = [
      {"Authorization", "Bearer #{access_token}"},
      {"Content-Type", "application/octet-stream"},
      {"Dropbox-API-Arg", Jason.encode!(%{
        "path" => dropbox_path,
        "mode" => "add",
        "autorename" => true,
        "mute" => false,
        "strict_conflict" => false
      })}
    ]

    case HTTPoison.post(@upload_url, file_content, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        IO.puts("File uploaded successfully: #{dropbox_path}")
        {:ok, Jason.decode!(body)}

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        IO.puts("Failed to upload file: #{status_code}")
        {:error, Jason.decode!(body)}

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect(reason)
        {:error, reason}
    end
  end

  def get_temporary_link(access_token, dropbox_path) do
    "get_temporary_link" |> IO.inspect()
    headers = [
      {"Authorization", "Bearer #{access_token}"},
      {"Content-Type", "application/json"}
    ]

    body = Jason.encode!(%{"path" => dropbox_path})

    case HTTPoison.post(@temporary_link_url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        %{"link" => url} = Jason.decode!(body)
        IO.puts("Temporary link obtained: #{url}")
        {:ok, url}

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        IO.puts("Failed to obtain temporary link: #{status_code}")
        IO.inspect(Jason.decode!(body), label: "Error details")
        {:error, Jason.decode!(body)}

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect(reason)
        {:error, reason}
    end
  end

  def delete_file(access_token, dropbox_path) do
    headers = [
      {"Authorization", "Bearer #{access_token}"},
      {"Content-Type", "application/json"}
    ]

    body = Jason.encode!(%{"path" => dropbox_path})

    case HTTPoison.post(@delete_url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        IO.puts("File deleted successfully: #{dropbox_path}")
        {:ok, Jason.decode!(body)}

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        IO.puts("Failed to delete file: #{status_code}")
        {:error, Jason.decode!(body)}

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts("Error: #{reason}")
        {:error, reason}
    end
  end


  def upload_and_get_link(local_path, dropbox_path) do
    "upload_and_get_link" |> IO.inspect()
    with {:ok, access_token} <- get_access_token(),
         {:ok, _} <- upload_file(access_token, local_path, dropbox_path),
         {:ok, url} <- get_temporary_link(access_token, dropbox_path) do
      {:ok, url}
    else
      error -> error
    end
  end

  def delete_uploaded_file(dropbox_path) do
    with {:ok, access_token} <- get_access_token(),
         {:ok, _} <- delete_file(access_token, dropbox_path) do
      IO.puts("File deleted successfully.")
      :ok
    else
      error -> error
    end
  end

end

# Example usage
if false do
  local_path = "/home/smpiun/Documents/Journey/journey-1682595279118_DL/1681642386485-3fea9157b297f3ce-3fd84fcd19f24294.webp"
  dropbox_path = "/dropbox/folder/file.webp"
  case DropboxUploader.upload_and_get_link(local_path, dropbox_path) do
    {:ok, url} -> IO.puts("Image URL: #{url}")
    {:error, reason} -> IO.inspect(reason)
  end
  # Example usage: Delete uploaded file
  case DropboxUploader.delete_uploaded_file(dropbox_path) do
    :ok -> IO.puts("Image deleted successfully.")
    {:error, reason} -> IO.inspect(reason)
  end
end
