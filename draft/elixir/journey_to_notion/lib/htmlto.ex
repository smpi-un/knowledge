defmodule HtmlToMarkdown do
  @moduledoc """
  Converts HTML content to Markdown format.
  """

  def convert(html) do
    # 一時ファイルを作成
    File.write!("/tmp/input.html", html)

    # pandocを呼び出してHTMLをMarkdownに変換
    {markdown, 0} = System.cmd("pandoc", ["-f", "html", "-t", "markdown", "/tmp/input.html"])

    markdown
  end

end

defmodule HtmlToPlaintext do
  @moduledoc """
  Converts HTML content to plain text.
  """

  def convert(html) do
    # 一時ファイルを作成
    File.write!("/tmp/input.html", html)

    # pandocを呼び出してHTMLをMarkdownに変換
    {markdown, 0} = System.cmd("pandoc", ["-f", "html", "-t", "plain", "/tmp/input.html"])

    markdown
  end
end

if false do
  path = "/home/smpiun/Documents/Journey/journey-1682595279118_DL/1682331623062-3feb4c91ebee71a4.json"
  {:ok, {_, jny, _, photos}} = Journey.load_journey(path)
  %{text: text} = jny
  # text |> IO.inspect()
  text |> HtmlToMarkdown.convert() |> IO.inspect()
  text |> HtmlToPlaintext.convert() |> IO.inspect()

  photos |> IO.inspect()
end
