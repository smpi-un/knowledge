defmodule HtmlToMarkdown do
  @moduledoc """
  Converts HTML content to Markdown format.
  """

  def convert(html) do
    # 一時ディレクトリを取得
    temp_dir = System.tmp_dir!()

    # 一時ファイルを作成
    File.write!(Path.join(temp_dir, "input.html"), html)

    # pandocを呼び出してHTMLをMarkdownに変換
    {markdown, 0} = System.cmd("pandoc", ["-f", "html", "-t", "markdown", Path.join(temp_dir, "input.html")])

    markdown
  end

end

defmodule HtmlToPlaintext do
  @moduledoc """
  Converts HTML content to plain text.
  """

  def convert(html) do
    # 一時ディレクトリを取得
    temp_dir = System.tmp_dir!()

    # 一時ファイルを作成
    File.write!(Path.join(temp_dir, "input.html"), html)

    # pandocを呼び出してHTMLをMarkdownに変換
    {markdown, 0} = System.cmd("pandoc", ["-f", "html", "-t", "plain", Path.join(temp_dir, "input.html")])

    markdown
  end
end
defmodule MarkdownToPlaintext do
  @moduledoc """
  Converts HTML content to plain text.
  """

  def convert(html) do
    # 一時ディレクトリを取得
    temp_dir = System.tmp_dir!()

    # 一時ファイルを作成
    File.write!(Path.join(temp_dir, "input.md"), html)

    # pandocを呼び出してHTMLをMarkdownに変換
    {markdown, 0} = System.cmd("pandoc", ["-f", "markdown", "-t", "plain", Path.join(temp_dir, "input.md")])

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
