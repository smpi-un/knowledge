defmodule MyApp.Application do
  use Application

  def start(_type, _args) do
    # Dotenv.load()

    children = [
      # Define workers and child supervisors to be supervised
    ]

    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end





defmodule Main do
  # alias Notion

  def run1 do
    args = System.argv()
    dir = case args do
      [path] -> path
      _ -> "."
    end
    Application.ensure_all_started(:httpoison)

    results = Journey.read_json_files(dir)
    results |> Enum.map(
      fn {:journey_cloud, journey, _, _} ->
        add_res = Notion.add_row(journey.id, journey.tags, journey.dateOfJournal, journey.text, [ "/home/smpiun/Documents/1681642386485-3fea9157b297f3ce-3fd84fcd19f24294.webp"])
        case add_res do
          {:error, reason} -> reason |> IO.inspect()
          _ -> ""
        end
        add_res
      end)
    |> IO.inspect()
  end

  def run2 do
    id = "12345"
    tag = "Elixir"
    date = "2023-01-01"
    content = "This is a test content."

    # https://elixirforum.com/t/httpoison-request-1st-argument-the-table-identifier-does-not-refer-to-an-existing-ets-table-when-calling-function-outside-module/53444/2
    Application.ensure_all_started(:httpoison)

    # notion_api_token = System.get_env("NOTION_API_TOKEN")
    # notion_database_id = System.get_env("NOTION_DATABASE_ID")
    # {notion_api_token, notion_database_id} |> IO.inspect()

    case Notion.add_row(id, tag, date, content, []) do

      {:ok, response} -> IO.inspect(response, label: "Success")
      {:error, reason} -> IO.inspect(reason, label: "Error")
      _ -> IO.inspect("Error!!!")
    end
  end
  def run3 do
    Application.ensure_all_started(:porcelain)

    input_path = "~/Documents/densanlinebot.drawio.png"
    input_path = "/home/smpiun/Documents/Journey/journey-1682595279118_DL/1681642386485-3fea9157b297f3ce-3fd84fcd19f24294.webp"
    output_path = "~/Documents/test_0.avif"
    ImageProcessor.resize_and_convert_to_avif(input_path, output_path)
  end

  def run4 do
    Application.ensure_all_started(:httpoison)
    path = "/home/smpiun/Documents/test_0.avif"
    path = "/home/smpiun/Documents/1681642386485-3fea9157b297f3ce-3fd84fcd19f24294.webp"
    GyazoUploader.upload_file(path)
  end

end

# Main.run1()
