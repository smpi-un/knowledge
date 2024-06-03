defmodule ImageProcessor do
  # 1920 x 1446
  # Pixel 8 Proの解像度4080 x 3072の横幅を1920に縮小
  @max_pixels 2_775_642

  def resize_and_convert_to_avif(input_path, output_path) do
    input_path
    |> Mogrify.open()
    |> Mogrify.verbose()
    |> handle_image(output_path)
  end

  defp handle_image(%Mogrify.Image{} = image, output_path) do
    %{width: width, height: height} = Mogrify.verbose(image)

    if width * height > @max_pixels do
      ratio = :math.sqrt(@max_pixels / (width * height))
      new_width = round(width * ratio)
      new_height = round(height * ratio)

      image
      |> Mogrify.resize("#{new_width}x#{new_height}")
      |> Mogrify.format("png")
      |> Mogrify.save(path: "temp_resized.png")

      convert_to_avif("temp_resized.png", output_path)
    else
      image
      |> Mogrify.format("png")
      |> Mogrify.save(path: "temp_original.png")

      convert_to_avif("temp_original.png", output_path)
    end
  end

  defp convert_to_avif(input_path, output_path) do
    # https://web.dev/articles/compress-images-avif?hl=ja&utm_source=pocket_saves
    # 公式推奨オプション
    # options_str = " --min 0 --max 63 -a end-usage=q -a cq-level=18 -a tune=ssim "
    # 高圧縮
    options_str = " --min 0 --max 63 -a end-usage=q -a cq-level=30 -a tune=ssim "
    # 可逆圧縮
    # options_str = " --min 0 --max 63 -a end-usage=q -a cq-level=0 -a tune=ssim "
    Porcelain.shell("avifenc #{options_str} #{input_path} #{output_path}")
    File.rm(input_path)
  end
end
