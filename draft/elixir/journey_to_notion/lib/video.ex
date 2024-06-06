defmodule VideoProcessor do
  def extract_frames(video_path, num_frames, output_dir) do
    # Create the output directory if it doesn't exist
    File.mkdir_p!(output_dir)

    # Get the duration of the video in seconds
    {duration_str, 0} = System.cmd("ffprobe", [
      "-v", "error",
      "-show_entries", "format=duration",
      "-of", "default=noprint_wrappers=1:nokey=1",
      video_path
    ])

    # Convert duration string to float
    duration = String.trim(duration_str) |> String.to_float()

    # Calculate the interval between frames
    interval = duration / (num_frames + 1)

    # Extract frames
    Enum.each(1..num_frames, fn i ->
      time = interval * i
      output_image_path = Path.join(output_dir, "frame_#{i}.png")
      {_, 0} = System.cmd("ffmpeg", [
        "-y",
        "-i", video_path,
        "-ss", "#{time}",
        "-vframes", "1",
        output_image_path
      ])
    end)

    :ok
  end
end

# Example usage
if false do
  VideoProcessor.extract_frames("/home/smpiun/Documents/Journey/journey-1681648736745_DL/1679191569285-3fe1835ba42b9a8f-3fecb21d813251e4.mp4", 5, "/home/smpiun/")
end
