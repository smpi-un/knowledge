defmodule S3Uploader do
  @moduledoc """
  A module for uploading files to S3 and retrieving the public URL.
  """

  Application.ensure_all_started(:httpoison)
  Application.ensure_all_started(:dotenv)
  Dotenv.load()
  @bucket "journey-medias" # 適切なバケット名を指定
  @region "us-east-1" # 適切なリージョンを指定
  @service "s3"
  @access_key System.get_env("AWS_ACCESS_KEY_ID")
  @secret_key System.get_env("AWS_SECRET_ACCESS_KEY")
  @access_key |> IO.inspect()
  @secret_key |> IO.inspect()

  alias Timex
  def upload_file(file_path, s3_key) do
    file_content = File.read!(file_path)
    datetime = Timex.now() |> Timex.format!("%Y%m%dT%H%M%SZ", :strftime)
    date = String.slice(datetime, 0..7)

    headers = generate_headers(s3_key, file_content, datetime, date)
    url = "https://#{@bucket}.s3.amazonaws.com/#{s3_key}"

    case HTTPoison.put(url, file_content, headers) do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        {:ok, public_url(s3_key)}

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, "Failed with status #{status_code}: #{body}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  defp generate_headers(s3_key, file_content, datetime, date) do
    amz_headers = [
      {"x-amz-content-sha256", :crypto.hash(:sha256, file_content) |> Base.encode16(case: :lower)},
      {"x-amz-date", datetime}
    ]

    canonical_request = """
    PUT
    /#{s3_key}

    host:#{@bucket}.s3.amazonaws.com
    x-amz-content-sha256:#{Enum.at(amz_headers, 0) |> elem(1)}
    x-amz-date:#{Enum.at(amz_headers, 1) |> elem(1)}

    host;x-amz-content-sha256;x-amz-date
    #{:crypto.hash(:sha256, file_content) |> Base.encode16(case: :lower)}
    """

    string_to_sign = """
    AWS4-HMAC-SHA256
    #{datetime}
    #{date}/#{@region}/#{@service}/aws4_request
    #{:crypto.hash(:sha256, canonical_request |> String.trim()) |> Base.encode16(case: :lower)}
    """

    signing_key = get_signing_key(date)
    signature = :crypto.mac(:hmac, :sha256, signing_key, string_to_sign |> String.trim()) |> Base.encode16(case: :lower)

    authorization_header = "AWS4-HMAC-SHA256 Credential=#{@access_key}/#{date}/#{@region}/#{@service}/aws4_request, SignedHeaders=host;x-amz-content-sha256;x-amz-date, Signature=#{signature}"

    [{"Authorization", authorization_header} | amz_headers]
  end

  defp get_signing_key(date) do
    k_date = :crypto.mac(:hmac, :sha256, "AWS4" <> @secret_key, date)
    k_region = :crypto.mac(:hmac, :sha256, k_date, @region)
    k_service = :crypto.mac(:hmac, :sha256, k_region, @service)
    :crypto.mac(:hmac, :sha256, k_service, "aws4_request")
  end

  defp public_url(s3_key) do
    "https://#{@bucket}.s3.amazonaws.com/#{s3_key}"
  end
end

if false do
  file_path = "/home/smpiun/Documents/Journey/journey-1682595279118_DL/1681642386485-3fea9157b297f3ce-3fd84fcd19f24294.webp"
  s3_key = "uploads/file.webp"

  case S3Uploader.upload_file(file_path, s3_key) do
    {:ok, url} ->
      IO.puts("File uploaded successfully. Public URL: #{url}")

    {:error, reason} ->
      IO.puts("Failed to upload file: #{reason}")
  end

end
