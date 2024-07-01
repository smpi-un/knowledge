from pytube import Playlist
import os
import json
import datetime



DEBUG = not True

def download_playlist(playlist_url: str, download_base_dir: str):


    # プレイリストオブジェクトを作成します
    playlist = Playlist(playlist_url)

    print(f'Downloading videos from playlist: {playlist.title}')

    # 各動画をダウンロードします
    for index, video in enumerate(playlist.videos, start=1):
        download_dir = os.path.join(download_base_dir, playlist.title)
        if not os.path.exists(download_dir):
            os.makedirs(download_dir)
        try:
            print(f'Downloading {video.title}...')
            # 公開日を取得し、YYYY-MM-DD形式に変換
            publish_date = video.publish_date.strftime('%Y%m%d')
            metadata = {
                'index': index,
                'title': video.title,
                'description': video.description,
                'publish_date': video.publish_date,
                'views': video.views,
                'rating': video.rating,
                'length': video.length,
                'thumbnail_url': video.thumbnail_url,
                'video_url': video.watch_url,
            }


            # ファイル名に通し番号、公開日、再生回数を付ける
            filename_body = f'{index:02d}_{publish_date}_{video.title}'

            video_filepath = os.path.join(download_dir, filename_body + '.mp4')
            metadata_filepath = os.path.join(download_dir, filename_body + '.json')
            # 最適なストリームを取得してダウンロードし、ファイル名を指定する
            if not DEBUG:
                video.streams.get_highest_resolution().download(filename=video_filepath)

            with open(metadata_filepath, 'w', encoding='utf-8') as fp:
                json.dump(metadata, fp, ensure_ascii=False, indent=4)

            print(f'Downloaded {video.title} successfully!')
        except Exception as e:
            print(f'An error occurred while downloading {video.title}: {e}')

def main():

    # プレイリストのURLを指定します
    playlist_urls = [
        # 'https://www.youtube.com/watch?v=7DOGxiqvq40&list=PLcP46opCIDc4PMoG8-TnBGxax2LygeIBb&pp=iAQB',
        'https://www.youtube.com/watch?v=YO4pa95WAqM&list=PLcP46opCIDc4DKBkYWDpEtx4JiHaRKhUh&pp=iAQB',
    ]

    for playlist_url in playlist_urls:
        download_playlist(playlist_url, '/home/smpiun/Documents/yt')


if __name__ == '__main__':
    main()