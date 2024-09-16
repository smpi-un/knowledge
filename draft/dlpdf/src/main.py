import os
import time
import pyperclip
import requests
import pdfkit
from datetime import datetime
from urllib.parse import urlparse
from bs4 import BeautifulSoup
import base64
import re

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

# 保存するフォルダ
SAVE_FOLDER = "saved_files"
if not os.path.exists(SAVE_FOLDER):
    os.makedirs(SAVE_FOLDER)

def get_page_metadata(url):
    response = requests.get(url)
    if response.status_code == 200:
        soup = BeautifulSoup(response.text, 'html.parser')
        title = soup.title.string if soup.title else 'No Title'
        tags = [meta.attrs.get('content') for meta in soup.find_all('meta', {'name': 'keywords'})]
        metadata = {
            'title': title.strip(),
            'tags': tags,
            'url': url,
            'date': datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        }
        return metadata
    return {'title': 'No Title', 'tags': [], 'url': url, 'date': datetime.now().strftime("%Y-%m-%d %H:%M:%S")}

def generate_file_name(num, title, extension):
    timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
    file_name = f"{num}_{title}_{timestamp}.{extension}"
    return file_name

def get_base64_encoded_image(url):
    response = requests.get(url)
    if response.status_code == 200:
        image_content = response.content
        encoded_image = base64.b64encode(image_content).decode('utf-8')
        return encoded_image
    return None

def save_url_as_markdown(url, file_name):
    try:
        response = requests.get(url)
        if response.status_code == 200:
            soup = BeautifulSoup(response.text, 'html.parser')
            metadata = get_page_metadata(url)
            markdown_content = f"---\n"
            markdown_content += f"title: {metadata['title']}\n"
            markdown_content += f"tags: {', '.join(metadata['tags'])}\n"
            markdown_content += f"url: {metadata['url']}\n"
            markdown_content += f"date: {metadata['date']}\n"
            markdown_content += f"---\n\n"

            # 画像をbase64で埋め込む
            for img in soup.find_all('img'):
                img_url = img['src']
                if not img_url.startswith(('http://', 'https://')):
                    img_url = urlparse(url)._replace(path=img_url).geturl()
                encoded_image = get_base64_encoded_image(img_url)
                if encoded_image:
                    markdown_content += f"![image](data:image/png;base64,{encoded_image})\n\n"

            # 他のコンテンツを追加
            for paragraph in soup.find_all('p'):
                markdown_content += f"{paragraph.get_text()}\n\n"

            # Markdownファイルとして保存
            file_path = sanitize_path(os.path.join(SAVE_FOLDER, file_name))
            with open(file_path, 'w', encoding='utf-8') as file:
                file.write(markdown_content)
            print(f"Saved: {file_path}")
        else:
            print(f"Failed to fetch {url}: Status code {response.status_code}")
    except Exception as e:
        print(f"Failed to save {url}: {e}")

def save_url_as_pdf(url, file_name):
    try:
        metadata = get_page_metadata(url)
        pdf_options = {
            'title': metadata['title'],
            # 'author': 'Auto Generated',
            # 'subject': ', '.join(metadata['tags']),
            # 'keywords': ', '.join(metadata['tags']),
            'custom-header': [
                ('url', metadata['url']),
                ('date', metadata['date'])
            ]
        }
        file_path = sanitize_path(os.path.join(SAVE_FOLDER, file_name))
        pdfkit.from_url(url, file_path, options=pdf_options)
        print(f"Saved: {file_path}")
    except Exception as e:
        print(f"Failed to save {url}: {e}")

def monitor_clipboard(save_format):
    recent_value = ""
    while True:
        time.sleep(1)  # 1秒ごとにクリップボードをチェック
        clipboard_value = pyperclip.paste()
        if clipboard_value != recent_value:
            if urlparse(clipboard_value).scheme in ["http", "https"]:
                print(f"Detected URL: {clipboard_value}")
                metadata = get_page_metadata(clipboard_value)
                extension = "md" if save_format == "markdown" else "pdf"
                file_name = generate_file_name("clipboard", metadata['title'], extension)
                if save_format == "markdown":
                    save_url_as_markdown(clipboard_value, file_name)
                else:
                    save_url_as_pdf(clipboard_value, file_name)
            recent_value = clipboard_value

def process_url_range(base_url, start_num, end_num, save_format):
    for num in range(start_num, end_num + 1):
        url = f"{base_url}{num}"
        try:
            response = requests.get(url)
            if response.status_code == 200:
                print(f"Processing URL: {url}")
                metadata = get_page_metadata(url)
                extension = "md" if save_format == "markdown" else "pdf"
                file_name = generate_file_name(num, metadata['title'], extension)
                if save_format == "markdown":
                    save_url_as_markdown(url, file_name)
                else:
                    save_url_as_pdf(url, file_name)
            else:
                print(f"URL not found: {url}")
        except Exception as e:
            print(f"Failed to process {url}: {e}")

if __name__ == "__main__":
    # 保存形式を選択: "markdown" または "pdf"
    save_format = "markdown"  # ここを "pdf" に変更すればPDFで保存されます
    
    # クリップボードの監視を開始
    # monitor_clipboard(save_format)
    
    # URLの範囲処理を実行
    # base_url = "https://kakomonn.com/chushoks/questions/"
    # # start_num = 43544
    # # end_num = 75543
    # start_num = 40544
    # end_num = 43544
    base_url = "https://kakomonn.com/itpass/questions/"
    # start_num = 43544
    # end_num = 75543
    start_num = 71178
    end_num = 71204
    # process_url_range(base_url, start_num, end_num, save_format)
    process_url_range(base_url, start_num, end_num, 'pdf')
