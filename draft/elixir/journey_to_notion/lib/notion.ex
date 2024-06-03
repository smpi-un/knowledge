defmodule Notion do
  @moduledoc """
  A module to interact with Notion API.
  """

  @notion_url "https://api.notion.com/v1/pages"
  @blocks_url "https://api.notion.com/v1/blocks"

  Application.ensure_all_started(:httpoison)
  Application.ensure_all_started(:dotenv)
  Dotenv.load()
  @notion_api_token System.get_env("NOTION_API_TOKEN")
  @notion_database_id System.get_env("NOTION_DATABASE_ID")

  def add_row(id, tags, date, content, photo_urls) do
    Dotenv.load()
    if row_exists?(id) do
      "skipped: #{id}" |> IO.inspect()
      {:error, "Row with ID #{id} already exists"}
    else
      "insert: #{id}" |> IO.inspect()
      headers = [
        {"Authorization", "Bearer #{@notion_api_token}"},
        {"Content-Type", "application/json"},
        {"Notion-Version", "2021-08-16"}
      ]

      body = %{
        "parent" => %{"database_id" => @notion_database_id},
        "properties" => %{
          "ID" => %{"title" => [%{"text" => %{"content" => id}}]},
          "タグ" => %{"multi_select" => tags |> Enum.map(fn tag -> %{"name" => tag} end)},
          "日付" => %{"date" => %{"start" => date}}
        },
        "children" => [
          %{
            "object" => "block",
            "type" => "paragraph",
            "paragraph" => %{
              "rich_text" => [%{"type" => "text", "text" => %{"content" => content}}]
            }
          }
        ]
      }
      |> Jason.encode!()

      case HTTPoison.post(@notion_url, body, headers) do
        {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
          response = Jason.decode!(response_body)
          page_id = response["id"]
          add_images_to_page(page_id, photo_urls, headers)
          {:ok, response}
        {:ok, %HTTPoison.Response{status_code: status_code, body: response_body}} ->
          {:error, %{status_code: status_code, body: Jason.decode!(response_body)}}
        {:error, %HTTPoison.Error{reason: reason}} ->
          {:error, reason}
      end
    end
  end


  defp add_images_to_page(page_id, photo_urls, headers) do
    photo_urls |> IO.inspect()
    res = photo_urls
    |> Enum.each(fn photo_url ->
      body = %{
        "children" => [
          %{
            "object" => "block",
            "type" => "image",
            "image" => %{"type" => "external", "external" => %{"url" => photo_url}}
          }
        ]
      }
      |> Jason.encode!()

      HTTPoison.patch("#{@blocks_url}/#{page_id}/children", body, headers)
    end)
    "------------------------" |> IO.inspect()
    res |> IO.inspect()
    res
  end


  defp row_exists?(id) do
    query_url = "https://api.notion.com/v1/databases/#{@notion_database_id}/query"

    headers = [
      {"Authorization", "Bearer #{@notion_api_token}"},
      {"Content-Type", "application/json"},
      {"Notion-Version", "2021-08-16"}
    ]

    body = %{
      "filter" => %{
        "property" => "ID",
        "title" => %{
          "contains" => id
        }
      }
    }
    |> Jason.encode!()

    case HTTPoison.post(query_url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        response = Jason.decode!(body)
        total_results = response["results"] |> length()
        total_results > 0
      {:ok, response} ->
        # response |> IO.inspect()
        true
      {:error, reason} ->
        reason |> IO.inspect()
        true
      nazo ->
        nazo |> IO.inspect()
        true
    end
  end

end

photo_path = "/home/smpiun/Documents/Journey/journey-1682595279118_DL/1681642386485-3fea9157b297f3ce-3fd84fcd19f24294.webp"
# dropbox_path = "/dropbox/folder/file2.webp"
# photo_url =
#   case DropboxUploader.upload_and_get_link(photo_path, dropbox_path) do
#     {:ok, url} ->
#       IO.puts("Image URL: #{url}")
#       url
#     {:error, reason} -> IO.inspect(reason)
#   end
{:ok, photo_url, photo_id} = GyazoUploader.upload_file(photo_path)
# photo_url = "https://m.media-amazon.com/images/S/aplus-media-library-service-media/f9ff116a-11f3-4676-891c-5b13813d56b7.__CR0,0,970,600_PT0_SX970_V1___.jpg"
photo_url |> IO.inspect()
res = Notion.add_row("testid27", [], "2024-06-03T23:00:00+09:00", "testtest", [photo_url])
GyazoUploader.delete_file(photo_id)
