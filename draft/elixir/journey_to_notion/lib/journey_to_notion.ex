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
    # {:ok, ids} = Notion.get_existing_ids()
    results |> Enum.map(
      fn {:journey_cloud, journey, _, _} ->
        # if journey.id not in ids do
          photo_paths = []
          text = case journey.type do
            "html" -> journey.text |> HtmlToPlaintext.convert |> String.slice(0, 1000-1)
            "markdown" -> journey.text |> MarkdownToPlaintext.convert |> String.slice(0, 1000-1)
          end
          contents = case journey.type do
            "html" -> journey.text |> HtmlToMarkdown.convert#  |> String.slice(0, 2000-1-87)
            "markdown" -> journey.text#  |> String.slice(0, 2000-1-87)
          end
          add_res = Notion.add_row(journey.id, journey.tags, journey.dateOfJournal, text, journey.address, journey.location, contents, photo_paths)
          case add_res do
            {:error, reason} -> reason |> IO.inspect()
            _ -> ""
          end
          add_res
        # end
      end)
    |> IO.inspect()
  end

  def run2 do
    Notion.delete_all_rows()
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

if true do
  Main.run1()
end
