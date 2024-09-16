from pytubefix import Playlist, YouTube
import pytubefix
import os
import json
import datetime
import subprocess
import requests
from tempfile import NamedTemporaryFile
import re
from PIL import Image
import urllib



def download_image(url):
    response = requests.get(url)
    response.raise_for_status()  # HTTPエラーチェック
    return response.content


def sanitize_path(path):
    # Windows上でファイル名に使えない文字のリスト
    invalid_chars = r'[<>:"/\\|?*&]'
    
    # ドライブレターのチェック（Windows用）
    drive, path_without_drive = os.path.splitdrive(path)
    
    # 全角の円記号を置き換える
    path_without_drive = path_without_drive.replace("￥", "_")
    
    # パスをディレクトリごとに分割
    parts = path_without_drive.split(os.sep)
    
    # 各パートを無効文字の置き換え処理
    sanitized_parts = [re.sub(invalid_chars, '_', part) for part in parts]
    
    # 再度パスとして結合
    sanitized_path = os.sep.join(sanitized_parts)
    
    # ドライブレターを元に戻す
    if drive:
        sanitized_path = drive + sanitized_path
    
    return sanitized_path


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
        download_dir = sanitize_path(os.path.join(download_base_dir, playlist.owner, playlist.title))
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
                'watch_url': video.watch_url,
                'video_id': video.video_id,
                'channel_id': video.channel_id,
            }
            # プレイリストのメタデータを追加
            metadata = {
                'playlist': playlist_metadata,
                'video': video_metadata
            }

            # ファイル名に通し番号、公開日、再生回数を付ける
            # また、長さを64文字以下に限定する
            filename_body = f'{index:02d}_{publish_date}_{video.title}'[0:64-1]

            video_filepath = sanitize_path(os.path.join(download_dir, filename_body + '.mp4'))
            metadata_filepath = sanitize_path(os.path.join(download_dir, filename_body + '.json'))
            audio_filepath = sanitize_path(os.path.join(download_dir, filename_body + '.m4a'))

            if os.path.exists(video_filepath) and os.path.exists(metadata_filepath) and os.path.exists(audio_filepath):
                print('skip')
                continue

            # 最適なストリームを取得してダウンロードし、ファイル名を指定する
            if not DEBUG:
                video.streams.get_highest_resolution().download(filename=video_filepath)
                add_tags_with_ffmpeg(video_filepath, video.title, video.author, playlist.title, video.publish_date.year, index, len(playlist.videos), "", playlist.owner, video.watch_url)
                # 一時ファイルにカバー画像を保存
                convert_mp4_to_opus_with_cover(video_filepath, video.thumbnail_url, audio_filepath, 3)

            print(f'Downloaded {video.title} successfully!')
            video_metadata_list.append(video_metadata)
            with open(metadata_filepath, 'w', encoding='utf-8') as fp:
                json.dump(metadata, fp, ensure_ascii=False, indent=4)

        except pytubefix.exceptions.MembersOnly as e:
            print(f'[MembersOnly] An error occurred while downloading {video.title}: {e}')
        except pytubefix.exceptions.RegexMatchError as e:
            print(f'[RegexMatchError] An error occurred while downloading {video.title}: {e}')
            print(f'{video.watch_url}')
            raise
        except urllib.error.HTTPError as e:
            print(f'[HTTPError] An error occurred while downloading {video.title}: {e}')
            print(f'{video.watch_url}')
        except pytubefix.exceptions.VideoUnavailable as e:
            print(f'[HTTPError] An error occurred while downloading {video.title}: {e}')
            print(f'{video.watch_url}')
        except Exception as e:
            print(f'An error occurred while downloading {video.title}: {e}')
            raise
    return {
        'playlist_metadata': playlist_metadata,
        'video_metadata_list': video_metadata_list,
    }

def add_tags_with_ffmpeg(audio_file, title, artist, album, year, track, total_tracks, composer, album_artist, watch_url):
    # ファイル拡張子を取得
    file_extension = os.path.splitext(audio_file)[1]
    temp_file = audio_file + ".temp" + file_extension

    # FFmpegコマンドを構築
    command = [
        'ffmpeg', '-i', audio_file,
        '-map', '0',
        '-metadata', f'title={title}',
        '-metadata', f'artist={artist}',
        '-metadata', f'album={album}',
        '-metadata', f'date={year}',
        '-metadata', f'track={track}/{total_tracks}',
        '-metadata', f'composer={composer}',
        '-metadata', f'album_artist={album_artist}',
        '-metadata', f'comment={watch_url}',
        # '-metadata', f'video_id={video_id}',
        '-c', 'copy',
        '-y', temp_file
    ]

    # FFmpegコマンドを実行
    subprocess.run(command, check=True)

    # 一時ファイルを元のファイルに置き換え
    os.replace(temp_file, audio_file)

def download_image(image_url):
    response = requests.get(image_url)
    if response.status_code != 200:
        raise Exception(f"Failed to download image from {image_url}")
    
    temp_image_file = NamedTemporaryFile(delete=False, suffix=os.path.splitext(image_url.split('?')[0])[1])
    temp_image_file.write(response.content)
    temp_image_file.close()
    return temp_image_file.name

# def convert_image_format(input_image_path, output_format):
#     output_image_path = NamedTemporaryFile(delete=False, suffix=f'.{output_format.lower()}').name
#     subprocess.run(['ffmpeg', '-i', input_image_path, '-y', output_image_path], check=True)
#     return output_image_path
def convert_image_to_jpeg(input_image_path):
    output_image_path = NamedTemporaryFile(delete=False, suffix='.jpeg').name
    subprocess.run(['ffmpeg', '-i', input_image_path, '-y', output_image_path], check=True)
    return output_image_path


def convert_mp4_to_opus_with_cover(mp4_path, image_url, output_opus_path, quality=5):
    # Download the cover image
    cover_image_path = download_image(image_url)
    
    # Convert image to the desired format if needed
    # cover_image_converted_path = convert_image_format(cover_image_path, cover_format)
    # cover_image_jpeg_path = convert_image_to_jpeg(cover_image_path)

    
    # Construct the ffmpeg command
    ffmpeg_command = [
        'ffmpeg',
        '-i', mp4_path,                    # Input MP4 file
        # '-i', cover_image_converted_path,  # Input cover image
        '-i', cover_image_path,  # Input cover image
        '-map', '0:a',                     # Map the audio from the first input
        '-map', '1:v',                       # Map the image from the second input
        # '-c:a', 'aac',                 # Encode audio to Opus
        # '-c:a', 'copy',                 # Encode audio to Opus
        # '-c:v', 'copy',                 # Encode audio to Opus
        '-c', 'copy',                 # Encode audio to Opus
        f'-compression_level', str(quality),# Set audio quality
        '-disposition:1', 'attached_pic',# Set the disposition for the image
        '-y',                              # Overwrite output files without asking
        output_opus_path                   # Output Opus file
    ]
    print(ffmpeg_command)
    
    # Run the ffmpeg command and capture output
    result = subprocess.run(ffmpeg_command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, encoding='utf-8')
    
    # Check for errors
    if result.returncode != 0:
        with open('ffmpeg_error_log.txt', 'w', encoding='utf-8') as f:
            f.write(result.stderr)
        print(f"FFmpeg error: {result.stderr}")
        raise subprocess.CalledProcessError(result.returncode, ffmpeg_command)
    
    # Clean up temporary image files
    # os.remove(cover_image_path)
    os.remove(cover_image_path)
    # os.remove(cover_image_converted_path)


def main_playlist():

    # プレイリストのURLを指定します
    playlist_urls = [
        # 'https://www.youtube.com/watch?v=7DOGxiqvq40&list=PLcP46opCIDc4PMoG8-TnBGxax2LygeIBb&pp=iAQB',
        # 'https://www.youtube.com/watch?v=Es3NUt0sUsM&list=PLcP46opCIDc5FSHT-2s5gQnQGfD_oI8Ww&pp=iAQB',
        # 'https://www.youtube.com/watch?v=wKYqGpcBMF8&list=PLcP46opCIDc6EQgXMj1X-Qf__qec7VjPO&pp=iAQB',
        # 'https://www.youtube.com/watch?v=YO4pa95WAqM&list=PLcP46opCIDc4DKBkYWDpEtx4JiHaRKhUh&pp=iAQB',
        # 'https://www.youtube.com/watch?v=YO4pa95WAqM&list=PLcP46opCIDc4DKBkYWDpEtx4JiHaRKhUh&pp=iAQB', 
        # 'https://www.youtube.com/watch?v=JOgP1JZ9JCo&list=PLSIOGjAheJuBkpqdbSI_LlYWPqe-O0wPa&pp=iAQB',
        # 'https://www.youtube.com/watch?v=44AWvQBWUH8&list=PLTVDiCkc_FCt_GitaQL0HcfrkHAltC6lG&pp=iAQB',
# 'https://www.youtube.com/watch?v=cDIuYb-dNic&list=PLTVDiCkc_FCt2EbeH24iUkrtgbyZvG9hk&pp=iAQB',
# 'https://www.youtube.com/watch?v=XFsjy11JG0c&list=PLTVDiCkc_FCtFuLQRw_hJOodoRixhn0HL&pp=iAQB',
# 'https://www.youtube.com/watch?v=3F7Hm89q9cs&list=PLTVDiCkc_FCslNqXBLttSmP8e-H1VFzqB&pp=iAQB',
# 'https://www.youtube.com/watch?v=tm4vEItHhi0&list=PLTVDiCkc_FCvDwFi7Hy_hxbP82WRqPJ-f&pp=iAQB',
# 'https://www.youtube.com/watch?v=V7eOtC_PDJ0&list=PLTVDiCkc_FCt9QAiLS0vukZel3CO_RNWB&pp=iAQB',
# 'https://www.youtube.com/watch?v=V7eOtC_PDJ0&list=PLTVDiCkc_FCt9QAiLS0vukZel3CO_RNWB&pp=iAQB',
  # 'https://www.youtube.com/watch?v=UmCcov-skgk&list=PLrVjFQqx1Ya57xZQIJnhM4KcCPqDFUsQ6&pp=iAQB',
  # 'https://www.youtube.com/watch?v=SuozQWFS5P4&list=PLrVjFQqx1Ya74opOdG_leHCOFAd2QMH3Y&pp=iAQB',
  # 'https://www.youtube.com/watch?v=fsnD9xQhxo8&list=PLrVjFQqx1Ya5pSs2XlhvHdNiJyxnRcUPb&pp=iAQB',
  # 'https://www.youtube.com/watch?v=sjOvOLuVKow&list=PLrVjFQqx1Ya5F77-1oAsE9rNrraAJQ0gL&pp=iAQB',
  # 'https://www.youtube.com/watch?v=fNX1mSwQut4&list=PLrVjFQqx1Ya7lfu1WuZeJIKlJSDdFVxjy&pp=iAQB',
  # 'https://www.youtube.com/watch?v=YSdkNVBVZqk&list=PLrVjFQqx1Ya7Lh7hxdPnA2THN3nbjRERB&pp=iAQB',
  # 'https://www.youtube.com/watch?v=Jz4sZ4QrGOw&list=PLrVjFQqx1Ya4fmYmfxE6h1JzQOh2uyoCX&pp=iAQB',
  # 'https://www.youtube.com/watch?v=Jz4sZ4QrGOw&list=PLrVjFQqx1Ya7YCKSGKnwZza4YLi1kFDSh&pp=iAQB',
  # 'https://www.youtube.com/watch?v=QVyNRzr2Hgc&list=PLrVjFQqx1Ya6Ox09PqPdAVIEEDT_D5J5X&pp=iAQB',
  # 'https://www.youtube.com/watch?v=I4fwvgQUrw8&list=PLW0sluvaHfnK6xg_qEwTDugXy2V6DqnHz&pp=iAQB',
  # 'https://www.youtube.com/watch?v=nUbkUwzIfZM&list=PLW0sluvaHfnKtZvIVc_RV-zaEiSRAM-Sr&pp=iAQB',
  # 'https://www.youtube.com/watch?v=Fo8B2bZXvws&list=PLW0sluvaHfnIbCF9q5czbBHblo5QRonF0&pp=iAQB',
  # 'https://www.youtube.com/watch?v=rv9MDDPgCsE&list=PLW0sluvaHfnLUTXGEZ-VGd2F--kYzySA7&pp=iAQB',
  # 'https://www.youtube.com/watch?v=M4z5bQAso30&list=PLW0sluvaHfnK9zPkKeqKnSlqGBKRDyowC&pp=iAQB',

    # 'https://www.youtube.com/watch?v=FP-6-R3b32A&list=PLYfEyegduK08nX44lE9ajZKsEgvj1VYAz',
    # 'https://www.youtube.com/watch?v=105Jy1v6z0Y&list=PLPGwNtcv_hNq5li75cOFAS7myl2LnMdBe',
    # 'https://www.youtube.com/watch?v=JHaYyruCp58&list=PLYfEyegduK08GSH4QDrIniT9ijN9K-U4W',
    # 'https://www.youtube.com/watch?v=cZy-5rMjpto&list=PLjXQAQOJ3dQcHIDwnTWuoHhm1UuLC8mIc',
    # 'https://www.youtube.com/watch?v=cZy-5rMjpto&list=PLjXQAQOJ3dQcHIDwnTWuoHhm1UuLC8mIc',

    # 'https://www.youtube.com/watch?v=5kMCuz6y-GU&list=PLKRlWvvHqFDSKmuILupOeZebKGJ3xOyaU',
    # 'https://www.youtube.com/watch?v=KHs8KXkkafc&list=PLKRlWvvHqFDQdDBwxVAToRlyNXNdGNOF3',
    # 'https://www.youtube.com/watch?v=EQLs6bj-bV8&list=PLQMbfcxzAs82O8sjxnkH17IxO9GgnDG1D',
    # 'https://www.youtube.com/watch?v=Kv2gCB-uviQ&list=PLQMbfcxzAs809eV6UcWBVtHP2D8Y8dJpJ',
    # 'https://www.youtube.com/watch?v=H2-smuWnTkQ&list=PLQMbfcxzAs80BRpJ60R0En4RuZdpDXMph',
    # 'https://www.youtube.com/watch?v=F-hhrQ3BjRI&list=PLcsZc78vRPlfkoMDiAfRGhoZDfXLHCDYj',
    # 'https://www.youtube.com/watch?v=lamug9E_5OE&list=PL81858E87075027C3',
    # 'https://www.youtube.com/watch?v=cCspsoPKs0U&list=FLIRjbgsjh_iu_vSl9dtwIDg',

    # 'https://www.youtube.com/watch?v=Mxx3QfFCT4k&list=PLjXQAQOJ3dQdwE_-l1KkJUo1INEoFYUSt',
    # 'https://www.youtube.com/watch?v=iyHXWaZvzv4&list=PLplrqdz3j00NaH8lLbB-oA80Q756-s_Ah',
    # 'https://www.youtube.com/watch?v=V7eOtC_PDJ0&list=PLTVDiCkc_FCt9QAiLS0vukZel3CO_RNWB',
    # 'https://www.youtube.com/watch?v=XrnOOzwWvJE&list=PLG2d5PjeVxclNte4yp08QOPwSUjKCeJuR&index=16',
    # 'https://www.youtube.com/watch?v=JiStlMx6rGI&list=PLG2d5PjeVxckDXQqTB69tIHGls0pXNS85',
    # 'https://www.youtube.com/watch?v=wKYqGpcBMF8&list=PLcP46opCIDc6EQgXMj1X-Qf__qec7VjPO',
    # 'https://www.youtube.com/watch?v=Es3NUt0sUsM&list=PLcP46opCIDc5FSHT-2s5gQnQGfD_oI8Ww&pp=iAQB',
    # 'https://www.youtube.com/watch?v=vqhwdxUaiw0&list=PLcP46opCIDc426k4TFZNv06wOgqwLOmZZ&pp=iAQB',

    # 'https://www.youtube.com/watch?v=vP-PmYy47Dk&list=PL4620ZpcJ9v85rrsrndq8pyYY8JY4aFvw',
    # 'https://www.youtube.com/watch?v=axEwJr76Eik&list=PL4620ZpcJ9v914W26fGCJ2ws_UX5Nz0Wc',
    # 'https://www.youtube.com/watch?v=XLQTh-iwNxQ&list=PL4620ZpcJ9v_rEUUwOmsup_4Rle0uSdT9',
    # 'https://www.youtube.com/watch?v=DdyGEjz0e28&list=PL4620ZpcJ9v9XTvZRUTk6BuWpCjVN191g',
    # 'https://www.youtube.com/watch?v=tEFnLYRffuQ&list=PLcAum0poprWFQDIBAlaOMbOQFrCd2NVSl&index=21',
    # 'https://www.youtube.com/watch?v=q4bNh3rA_cE&list=PLcAum0poprWGjJzDiCm3RBuIZ_kL8yeQf',
    # 'https://www.youtube.com/watch?v=tEFnLYRffuQ&list=PLcAum0poprWEGKTiqFt5W8PKuN23wyGJN',
    # 'https://www.youtube.com/watch?v=pr5E5vzblec&list=PLL1h9mgddU4w3hGqNRbN1EK45k9X5dSRm',

    # 'https://www.youtube.com/watch?v=suWIcQ3c1a4&list=PL_6LToJSSAAAavmksAkJ--LEZuBpiQ2oy&pp=iAQB',
    # 'https://www.youtube.com/watch?v=D41MgbwqYmk&list=PL_6LToJSSAAAlMtjUKYA0GXmIiVzntKrK&pp=iAQB',
    # 'https://www.youtube.com/watch?v=5v_IxPB94_Y&list=PL_6LToJSSAABoNtMffwOllHZ7vKIoFe5r&pp=iAQB',
    # 'https://www.youtube.com/watch?v=oMZb8G62Lro&list=PL_6LToJSSAADE9bSYS5P1Dn0rU0gzunSu&pp=iAQB',
    # 'https://www.youtube.com/watch?v=P5L9-hM9WzQ&list=PLXwUYcyFjUrs1BapC3y5KKJasEdqqk87d&pp=iAQB',
    # 'https://www.youtube.com/watch?v=ZhcP75DlIZg&list=PLXwUYcyFjUrvrza_bF6u6AfUjBgydSrBC&pp=iAQB',

    # 'https://www.youtube.com/watch?v=8VUjThYylwk&list=PLW0sluvaHfnKaeqxHbgv4393TR9WFo3w-&pp=iAQB',
    # 'https://www.youtube.com/watch?v=_2-OlpIf7WA&list=PLW0sluvaHfnLdMWYSqQ3NgQUHB1F4A4i1&pp=iAQB',

    'https://www.youtube.com/watch?v=mtsPtVsQm7k&list=PLOK_FwsuF0Q1a36eUdgCOicHuVXm0Il4L&pp=iAQB',
    'https://www.youtube.com/watch?v=E_99avvNbPU&list=PLOK_FwsuF0Q3JNAAdlJyMHiSZVaXyU3lZ&pp=iAQB',
    'https://www.youtube.com/watch?v=3CTI_QasN4U&list=PLOK_FwsuF0Q0Denr74xNnnu9d8-_yN_ar&pp=iAQB',

    'https://www.youtube.com/watch?v=WbVGW-y250s&list=PLVckPSjIWVdEgusbZjenuSmAbXZsUPMEy&pp=iAQB',
    'https://www.youtube.com/watch?v=-cHj5RDO4N8&list=PLVckPSjIWVdHsN44YHC4ylbLvFQ1lZMiZ&pp=iAQB',
    'https://www.youtube.com/watch?v=NCQSqktyK3I&list=PLVckPSjIWVdGDDjrdct8vYQENA-8Q9JSJ&pp=iAQB',
    ]
    out_dir = r'/home/smpiun/Documents/yt'
    out_dir = r'I:\yt'

    for playlist_url in playlist_urls:
        metadata = download_playlist(playlist_url, out_dir)
        # for video_metadata in metadata['video_metadata_list']:

def main_single():
    video_urls = [
        r'https://www.youtube.com/watch?v=Tp3qiOKuEBM'
    ]
    download_base_dir = r'C:\Users\shimp\Downloads'
    download_dir = os.path.join(download_base_dir, 'single', 'single')
    for url in video_urls:
        video = YouTube(url)
        print(video)
        print(video.streams)
        print(len(video.streams))

        # 音声を含むストリームを取得（通常は最高解像度）
        # stream = video.streams.filter(progressive=True, file_extension='mp4').order_by('resolution').desc().first()

        # 動画のダウンロード（現在のディレクトリに保存）
        # stream.download()
        if not os.path.exists(download_dir):
            os.makedirs(download_dir)
        try:
            print(f'Downloading {video.title}...')
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
                'watch_url': video.watch_url,
                'video_id': video.video_id,
                'channel_id': video.channel_id,
            }
            # プレイリストのメタデータを追加
            metadata = {
                'video': video_metadata
            }

            # ファイル名に通し番号、公開日、再生回数を付ける
            # また、長さを64文字以下に限定する
            filename_body = f'{publish_date}_{video.title}'[0:64-1]

            video_filepath = sanitize_path(os.path.join(download_dir, filename_body + '.mp4'))
            metadata_filepath = sanitize_path(os.path.join(download_dir, filename_body + '.json'))
            audio_filepath = sanitize_path(os.path.join(download_dir, filename_body + '.m4a'))

            if os.path.exists(video_filepath) and os.path.exists(metadata_filepath) and os.path.exists(audio_filepath):
                print('skip')
                continue

            # 最適なストリームを取得してダウンロードし、ファイル名を指定する
            if not DEBUG:
                # video.streams.get_highest_resolution().download(filename=video_filepath)
                stream = video.streams.first()
                stream.download(filename=video_filepath)
                add_tags_with_ffmpeg(video_filepath, video.title, video.author, playlist.title, video.publish_date.year, index, len(playlist.videos), "", playlist.owner, video.watch_url)
                # 一時ファイルにカバー画像を保存
                convert_mp4_to_opus_with_cover(video_filepath, video.thumbnail_url, audio_filepath, 3)

            print(f'Downloaded {video.title} successfully!')
            video_metadata_list.append(video_metadata)
            with open(metadata_filepath, 'w', encoding='utf-8') as fp:
                json.dump(metadata, fp, ensure_ascii=False, indent=4)

        except pytube.exceptions.MembersOnly as e:
            print(f'[MembersOnly] An error occurred while downloading {video.title}: {e}')
        except pytube.exceptions.RegexMatchError as e:
            print(f'[RegexMatchError] An error occurred while downloading {video.title}: {e}')
            print(f'{video.watch_url}')
        except urllib.error.HTTPError as e:
            print(f'[HTTPError] An error occurred while downloading {video.title}: {e}')
            print(f'{video.watch_url}')
        except Exception as e:
            print(f'An error occurred while downloading {video.title}: {e}')
            raise




if __name__ == '__main__':
    main_playlist()