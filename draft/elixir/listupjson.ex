defmodule JsonFileLister do
  def list_json_files(dir \\ ".") do
    dir
    |> Path.expand()
    |> Path.join("**/*.json")
    |> Path.wildcard()
    |> Enum.map(&Path.relative_to(&1, dir))
  end
end

defmodule Main do
  def run do
    args = System.argv()
    dir = case args do
      [path] -> path
      _ -> "."
    end

    JsonFileLister.list_json_files(dir)
    |> Enum.each(&IO.puts/1)
  end
end

Main.run()
