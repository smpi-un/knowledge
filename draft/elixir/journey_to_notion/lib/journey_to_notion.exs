# import jason
defmodule MyApp.Application do
  use Application

  def start(_type, _args) do
    Dotenv.load()

    children = [
      # Define workers and child supervisors to be supervised
    ]

    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

defmodule JourneyToNotion do
  @moduledoc """
  A module to read JSON files and match them to specific structures.
  """

  def read_json_files(dir) do
    dir
    |> Path.expand()
    |> Path.join("**/*.json")
    |> Path.wildcard()
    |> Enum.map(&File.read/1)
    |> Enum.filter(fn {:ok, _} -> true; _ -> false end)
    |> Enum.map(fn {:ok, data} -> data; end)
    |> Enum.map(&parse_json/1)
    |> Enum.filter(fn {:ok, _} -> true; _ -> false end)
    |> Enum.map(fn {:ok, data} -> data; end)
    # |> Enum.filter_map(&parse_json/1, fn {:ok, data} -> data end)
  end

  defp parse_json(content) do
    Jason.decode(content)
    |> parse_journey
  end

  defp parse_journey({:ok, %{
    "id" => id,
    "text" => text,
    "dateOfJournal" => dateOfJournal,
    "address" => address,
    "location" => location,
    "weather" => weather,
    # "weather" => %{"icon"=> icon, "description"=> description, "id"=> id, "place"=> place, "degreeC"=> degreeC}
  } = d}) do
    l = case location do
      %{"lat"=> lat, "lng"=> lng} -> %{lat: lat, lng: lng}
      _ -> nil
    end
    w = case weather do
      %{"icon"=> icon, "description"=> description, "id"=> id, "place"=> place, "degreeC"=> degreeC}
        -> %{icon: icon, description: description, id: id, place: place, degreeC: degreeC}
      _ -> nil
    end
    data = %{
      id: id,
      text: text,
      dateOfJournal: dateOfJournal,
      address: address,
      location: l,
      weather: w,
    }
    {:ok, {:journey_cloud, data}}
  end

  defp parse_journey({:ok, %{
    "id" => id,
    "text" => text,
    "date_modified" => dateModified,
    "date_journal" => dateJournal,
    "preview_text" => previewText,
    "address" => address,
    "music_artist" => musicArtist,
    "music_title" => musicTitle,
    "lat" => lat,
    "lon" => lon,
    "mood" => mood,
    "label" => label,
    "folder" => folder,
    "sentiment" => sentiment,
    "timezone" => timezone,
    "favourite" => favourite,
    "type" => type,
    "linked_account_id" => linkedAccountId,
    # "weather" => %{"id"=> id, "degree_c"=> degreeC, "description"=> description, "icon"=> icon, "place"=> place},
    "weather" => weather,
    "photos" => photos,
    "tags" => tags
  }}) do
    w = case weather do
      %{"icon"=> icon, "description"=> description, "id"=> id, "place"=> place, "degree_c"=> degreeC}
        -> %{icon: icon, description: description, id: id, place: place, degreeC: degreeC}
      _ -> nil
    end
    data = %{
      id: id,
      text: text,
      dateOfJournal: dateJournal,
      address: address,
      location: %{lat: lat, lng: lon},
      weather: w,
      music: %{artist: musicArtist, title: musicTitle}
    }
    {:ok, {:journey_cloud, data}}
  end
  defp parse_journey(_) do
    IO.inspect("err")
    :error
  end



end


defmodule Notion do
  @moduledoc """
  A module to interact with Notion API.
  """

  # @notion_token Application.get_env(:my_app, :notion)[:token]
  # @database_id Application.get_env(:my_app, :notion)[:database_id]
  @notion_url "https://api.notion.com/v1/pages"

  def add_row(id, tag, date, content) do
    notion_api_token = System.get_env("NOTION_API_TOKEN")
    notion_database_id = System.get_env("NOTION_DATABASE_ID")
    notion_token = ""
    headers = [
      {"Authorization", "Bearer #{notion_api_token}"},
      {"Content-Type", "application/json"},
      {"Notion-Version", "2021-08-16"}
    ]

    body = %{
      "parent" => %{"database_id" => notion_database_id},
      "properties" => %{
        "ID" => %{"title" => [%{"text" => %{"content" => id}}]},
        "タグ" => %{"multi_select" => [%{"name" => tag}]},
        "日付" => %{"date" => %{"start" => date}},
        "本文" => %{"rich_text" => [%{"text" => %{"content" => content}}]}
      }
    }
    |> Jason.encode!()

    HTTPoison.post(@notion_url, body, headers)
    |> handle_response()
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    {:ok, Jason.decode!(body)}
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: status_code, body: body}}) do
    {:error, %{status_code: status_code, body: Jason.decode!(body)}}
  end

  defp handle_response({:error, %HTTPoison.Error{reason: reason}}) do
    {:error, reason}
  end
end


defmodule Main do
  def run do
    args = System.argv()
    dir = case args do
      [path] -> path
      _ -> "."
    end

    results = JourneyToNotion.read_json_files(dir)

    IO.inspect(results)
  end

  def run2 do
    id = "12345"
    tag = "Elixir"
    date = "2023-01-01"
    content = "This is a test content."

    Dotenv.load
    notion_api_token = System.get_env("NOTION_API_TOKEN")
    notion_database_id = System.get_env("NOTION_DATABASE_ID")
    {notion_api_token, notion_database_id} |> IO.inspect()

    case Notion.add_row(id, tag, date, content) do

      {:ok, response} -> IO.inspect(response, label: "Success")
      {:error, reason} -> IO.inspect(reason, label: "Error")
    end
  end

end

Main.run2()
