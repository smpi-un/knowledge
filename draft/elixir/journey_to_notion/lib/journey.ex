defmodule Journey do
  @moduledoc """
  A module to read JSON files and match them to specific structures.
  """

  def read_json_files(dir) do
    dir
    |> Path.expand()
    |> Path.join("**/*.json")
    |> Path.wildcard()
    # |> Enum.map(&File.read/1)
    # |> Enum.filter(fn {:ok, _} -> true; _ -> false end)
    # |> Enum.map(fn {:ok, data} -> data; end)
    # |> Enum.map(&parse_json/1)
    |> Enum.map(&load_journey/1)
    |> Enum.filter(fn {:ok, _} -> true; _ -> false end)
    |> Enum.map(fn {:ok, data} -> data; end)
    # |> Enum.filter_map(&parse_json/1, fn {:ok, data} -> data end)
  end

  def load_journey(path) do
    case path |> File.read do
      {:ok, data} -> case parse_json(path, data
                          |> String.replace("1.797693134862316e+308", "null")
                          |> String.replace("1.7976931348623157E308", "null")
                          ) do
        {:ok, _} = journey_res -> journey_res
        error -> error
      end
      error -> error
    end
  end

  defp parse_json(path, content) do
    json_data = Jason.decode(content)
    parse_journey(path, json_data)
  end

  defp parse_journey(path, {:ok, %{
    "id" => id,
    "text" => text,
    "dateOfJournal" => dateOfJournal,
    "address" => address,
    "location" => location,
    "weather" => weather,
    "tags" => tags,
    "type" => type,
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
      tags: tags,
      type: type,
    }
    {:ok, {:journey_cloud, data, path, []}}
  end

  defp parse_journey(path, {:ok, %{
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
      dateOfJournal: dateJournal |> Integer.floor_div(1000) |> DateTime.from_unix!() |> DateTime.to_iso8601(),
      address: address,
      location: %{lat: lat, lng: lon},
      weather: w,
      music: %{artist: musicArtist, title: musicTitle},
      tags: tags,
      type: type,
    }
    {:ok, {:journey_cloud, data, path, photos}}
  end
  defp parse_journey(_) do
    IO.inspect("err")
    :error
  end

end
