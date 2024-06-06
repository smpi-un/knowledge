defmodule Base64Encoder do
  def encode_file_to_base64(file_path) do
    case File.read(file_path) do
      {:ok, file_content} ->
        Base.encode64(file_content)

      {:error, reason} ->
        "Error reading file: #{reason}"
    end
  end
end

# 実行例
if false do
  file_path = "/home/smpiun/Documents/Journey/journey-1682595279118_DL/1681642386485-3fea9157b297f3ce-3fd84fcd19f24294.webp"
  IO.puts Base64Encoder.encode_file_to_base64(file_path)
end
