from pytube import YouTube

urls = [

"https://www.youtube.com/watch?v=9y7GrSkjqNU",
"https://www.youtube.com/watch?v=PSn5CZcusVQ",
"https://www.youtube.com/watch?v=CDsZDo8kK3M",
"https://www.youtube.com/watch?v=c_PpfINLdvQ",
"https://www.youtube.com/watch?v=WkZe5GhuvYQ",
"https://www.youtube.com/watch?v=Y37T2DvU2Tk",
"https://www.youtube.com/watch?v=fNX1mSwQut4",
"https://www.youtube.com/watch?v=KmmqBSv04ew",
"https://www.youtube.com/watch?v=5DelKC74LHE",
"https://www.youtube.com/watch?v=bzHBK6CPwB0",
"https://www.youtube.com/watch?v=FmMpqty4AaI",
"https://www.youtube.com/watch?v=R6cr9Zzmeeg",
"https://www.youtube.com/watch?v=YSdkNVBVZqk",
"https://www.youtube.com/watch?v=8XgbwI9gK_4",
"https://www.youtube.com/watch?v=Im0rjWg1V1o",
"https://www.youtube.com/watch?v=B68VWFoRJ74",
"https://www.youtube.com/watch?v=qgK82nksS7A",
"https://www.youtube.com/watch?v=8SGu_rTUYJ0",
"https://www.youtube.com/watch?v=vm_QCkFKaOA",
"https://www.youtube.com/watch?v=rWEMfmhO4nM",
"https://www.youtube.com/watch?v=w1xmg09Fr7o",
"https://www.youtube.com/watch?v=oMVFQzSlM8I",
"https://www.youtube.com/watch?v=7pd_8N_Rs6M",
"https://www.youtube.com/watch?v=slDF949WPCg",
"https://www.youtube.com/watch?v=xVWw3hZ_loI",
"https://www.youtube.com/watch?v=XJ8cYqdUu94",
"https://www.youtube.com/watch?v=fgFbNhuYXYI",
"https://www.youtube.com/watch?v=FYcHUi7oebM",
"https://www.youtube.com/watch?v=PWXxp-FWa70",
"https://www.youtube.com/watch?v=HHAxRo-6v1M",
"https://www.youtube.com/watch?v=Jz4sZ4QrGOw",
]
# 64

for url in urls:
    print(url)
    yt = YouTube(url)

    # 音声を含むストリームを取得（通常は最高解像度）
    stream = yt.streams.filter(progressive=True, file_extension='mp4').order_by('resolution').desc().first()

    # 動画のダウンロード（現在のディレクトリに保存）
    stream.download()

