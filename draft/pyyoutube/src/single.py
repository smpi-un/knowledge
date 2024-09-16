from pytube import YouTube

urls = [

]
# 64

for url in urls:
    print(url)
    yt = YouTube(url)

    # 音声を含むストリームを取得（通常は最高解像度）
    stream = yt.streams.filter(progressive=True, file_extension='mp4').order_by('resolution').desc().first()

    # 動画のダウンロード（現在のディレクトリに保存）
    stream.download()

