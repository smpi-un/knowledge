from pytube import Playlist
import os
import json
import datetime
import subprocess
import requests
from tempfile import NamedTemporaryFile


def download_image(url):
    response = requests.get(url)
    response.raise_for_status()  # HTTPエラーチェック
    return response.content




DEBUG = not True

def download_playlist(playlist_url: str, download_base_dir: str):

    # プレイリストオブジェクトを作成します
    playlist = Playlist(playlist_url)
    # プレイリストのメタデータを取得
    playlist_metadata = {
        'title': playlist.title,
        # 'description': playlist.description,
        'owner': playlist.owner,
        'total_videos': len(playlist.video_urls)
    }

    video_metadata_list = []

    print(f'Downloading videos from playlist: {playlist.title}')

    # 各動画をダウンロードします
    for index, video in enumerate(playlist.videos, start=1):
        download_dir = os.path.join(download_base_dir, playlist.owner, playlist.title)
        if not os.path.exists(download_dir):
            os.makedirs(download_dir)
        try:
            print(f'{index}: Downloading {video.title}...')
            # 公開日を取得し、YYYY-MM-DD形式に変換
            publish_date = video.publish_date.strftime('%Y%m%d')
            # 動画のメタデータを取得
            video_metadata = {
                'title': video.title,
                'description': video.description,
                'publish_date': publish_date,
                'views': video.views,
                'rating': video.rating,
                'length': video.length,
                'thumbnail_url': video.thumbnail_url,
                'author': video.author,
                'keywords': video.keywords,
            }
            # プレイリストのメタデータを追加
            metadata = {
                'playlist': playlist_metadata,
                'video': video_metadata
            }

            # ファイル名に通し番号、公開日、再生回数を付ける
            filename_body = f'{index:02d}_{publish_date}_{video.title}'

            video_filepath = os.path.join(download_dir, filename_body + '.mp4')
            metadata_filepath = os.path.join(download_dir, filename_body + '.json')

            if os.path.exists(video_filepath) or os.path.exists(metadata_filepath):
                print('skip')
                continue

            # 最適なストリームを取得してダウンロードし、ファイル名を指定する
            if not DEBUG:
                video.streams.get_highest_resolution().download(filename=video_filepath)

            with open(metadata_filepath, 'w', encoding='utf-8') as fp:
                json.dump(metadata, fp, ensure_ascii=False, indent=4)

            print(f'Downloaded {video.title} successfully!')
            video_metadata_list.append(video_metadata)
            # 一時ファイルにカバー画像を保存
            cover_image_data = download_image(video.thumbnail_url)
            with NamedTemporaryFile(delete=False, suffix=".jpg") as tmp_cover_file:
                tmp_cover_file.write(cover_image_data)
                cover_image_path = tmp_cover_file.name

                add_tags_and_cover_with_ffmpeg(video_filepath, video.title, video.author, playlist.title, video.publish_date.year, index, cover_image_path)
        except Exception as e:
            print(f'An error occurred while downloading {video.title}: {e}')
    return {
        'playlist_metadata': playlist_metadata,
        'video_metadata_list': video_metadata_list,
    }

def add_tags_and_cover_with_ffmpeg(audio_file, title, artist, album, year, track, cover_image_path):
    # ファイル拡張子を取得
    file_extension = os.path.splitext(audio_file)[1]
    temp_file = audio_file + ".temp" + file_extension

            # FFmpegコマンドを構築
    command = [
        'ffmpeg', '-i', audio_file,
    ]
    
    if cover_image_path is not None:
        command.extend([
            '-i', cover_image_path,
            '-map', '0', '-map', '1',
            '-c', 'copy', '-id3v2_version', '3',
            '-metadata:s:v', 'title=Album cover',
            '-metadata:s:v', 'comment=Cover (front)',
        ])
    else:
        command.extend(['-c', 'copy'])

    command.extend([
        '-metadata', f'title={title}',
        '-metadata', f'artist={artist}',
        '-metadata', f'album={album}',
        '-metadata', f'date={year}',
        '-metadata', f'track={track}',
        '-y', temp_file
    ])

    # FFmpegコマンドを実行
    subprocess.run(command, check=True)

    # 一時ファイルを元のファイルに置き換え
    os.replace(temp_file, audio_file)






def main():

    # プレイリストのURLを指定します
    playlist_urls = [
        # 'https://www.youtube.com/watch?v=7DOGxiqvq40&list=PLcP46opCIDc4PMoG8-TnBGxax2LygeIBb&pp=iAQB',
        # 'https://www.youtube.com/watch?v=Es3NUt0sUsM&list=PLcP46opCIDc5FSHT-2s5gQnQGfD_oI8Ww&pp=iAQB',
        'https://www.youtube.com/watch?v=wKYqGpcBMF8&list=PLcP46opCIDc6EQgXMj1X-Qf__qec7VjPO&pp=iAQB',
        'https://www.youtube.com/watch?v=YO4pa95WAqM&list=PLcP46opCIDc4DKBkYWDpEtx4JiHaRKhUh&pp=iAQB',
    ]
    out_dir = r'/home/smpiun/Documents/yt'
    out_dir = r'C:\Users\shimp\Downloads'

    for playlist_url in playlist_urls:
        metadata = download_playlist(playlist_url, out_dir)
        # for video_metadata in metadata['video_metadata_list']:



if __name__ == '__main__':
    main()