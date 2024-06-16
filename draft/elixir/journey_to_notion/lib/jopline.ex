defmodule JoplinClient do
  @moduledoc """
  A simple client for posting notes with attachments to a Joplin server.
  """

  @base_url "http://your-joplin-server-url:41184"
  @token "your_authentication_token"

  def post_note_with_attachment(title, body, file_path) do
    case upload_file(file_path) do
      {:ok, resource_id} ->
        body_with_attachment = "#{body}\n[attachment](:/#{resource_id})"
        post_note(title, body_with_attachment)

      {:error, reason} ->
        IO.puts("Failed to upload file: #{reason}")
    end
  end

  defp post_note(title, body) do
    url = "#{@base_url}/notes?token=#{@token}"
    headers = [{"Content-Type", "application/json"}]
    note = %{
      "title" => title,
      "body" => body
    }
    |> Jason.encode!()

    case HTTPoison.post(url, note, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        IO.puts("Note posted successfully!")
        IO.inspect(body)

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        IO.puts("Failed to post note. Status code: #{status_code}")

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts("Error: #{reason}")
    end
  end

  defp upload_file(file_path) do
    url = "#{@base_url}/resources?token=#{@token}"
    headers = [
      {"Content-Type", "multipart/form-data"}
    ]

    {:ok, file_data} = File.read(file_path)
    filename = Path.basename(file_path)
    mime_type = MIME.from_path(file_path)

    form_data = {
      :multipart, [
        {:file, file_data, {"form-data", [{"name", "file"}, {"filename", filename}]}, [{"Content-Type", mime_type}]}
      ]
    }

    case HTTPoison.post(url, form_data, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"id" => resource_id}} ->
            {:ok, resource_id}

          {:error, reason} ->
            {:error, reason}
        end

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, "Failed to upload file. Status code: #{status_code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end

if false do
  # 実際の投稿例
  JoplinClient.post_note_with_attachment("Sample Note with Attachment", "This is a sample note body.", "path/to/your/file.txt")
end
