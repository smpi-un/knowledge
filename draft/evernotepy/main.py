# -*- coding: utf-8 -*-
import os
import hashlib
import urlparse
import requests
from requests_oauthlib import OAuth1
from evernote.api.client import EvernoteClient
import evernote.edam.type.ttypes as Types
import evernote.edam.error.ttypes as Errors
from dotenv import load_dotenv



# .envファイルを読み込む
load_dotenv()

# Evernote APIのConsumer KeyとConsumer Secretを環境変数から取得
consumer_key = os.getenv('EVERNOTE_CONSUMER_KEY')
consumer_secret = os.getenv('EVERNOTE_CONSUMER_SECRET')

# OAuth認証のURL（本番環境を使用）
request_token_url = "https://www.evernote.com/oauth"
access_token_url = "https://www.evernote.com/oauth"
authorize_url = "https://www.evernote.com/OAuth.action"

# OAuthクライアントの作成
oauth = OAuth1(consumer_key, client_secret=consumer_secret)
response = requests.post(request_token_url, auth=oauth)

# レスポンス内容を出力してデバッグ
print("Response status code:", response.status_code)
print("Response content:", response.content)

# レスポンスを辞書に変換
request_tokens = dict(urlparse.parse_qsl(response.content.decode('utf-8')))

# デバッグのため、トークンの内容を出力
print("Request tokens:", request_tokens)

# OAuthトークンを取得
resource_owner_key = request_tokens.get('oauth_token')
resource_owner_secret = request_tokens.get('oauth_token_secret')

# トークンが取得できているか確認
if not resource_owner_key or not resource_owner_secret:
    raise Exception("Failed to obtain OAuth token. Check your consumer key/secret and network connection.")

# 認証用URLの生成
authorization_url = '{}?oauth_token={}'.format(authorize_url, resource_owner_key)
print('Please go here and authorize:', authorization_url)
verifier = raw_input('Please input the verifier: ')

# アクセストークンの取得
oauth = OAuth1(consumer_key,
               client_secret=consumer_secret,
               resource_owner_key=resource_owner_key,
               resource_owner_secret=resource_owner_secret,
               verifier=verifier)
response = requests.post(access_token_url, auth=oauth)

# レスポンス内容を出力してデバッグ
print("Access token response status code:", response.status_code)
print("Access token response content:", response.content)

# レスポンスを辞書に変換
access_tokens = dict(urlparse.parse_qsl(response.content.decode('utf-8')))

oauth_token = access_tokens.get('oauth_token')
oauth_token_secret = access_tokens.get('oauth_token_secret')

# トークンが取得できているか確認
if not oauth_token or not oauth_token_secret:
    raise Exception("Failed to obtain access token. Check your verifier code and network connection.")

# Evernoteクライアントの作成
client = EvernoteClient(token=oauth_token, sandbox=False)  # 本番環境を使用するためsandbox=Falseに変更
note_store = client.get_note_store()

# 新しいノートの作成
note = Types.Note()
note.title = "Sample Note with Attachments"

# ノートの内容
content = """
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">
<en-note>Here is some content with attachments:<br/>
<img src="evernote:///res/{image_guid}"/>
<audio controls src="evernote:///res/{audio_guid}">Your browser does not support the audio element.</audio>
<en-media type="application/pdf" hash="{pdf_hash}"/>
</en-note>
"""

note.content = content

# 画像の追加
# image_data = open('path/to/your/image.jpg', 'rb').read()
# image = Types.Resource()
# image.data = Types.Data()
# image.data.size = len(image_data)
# image.data.bodyHash = hashlib.md5(image_data).digest()
# image.data.body = image_data
# image.mime = 'image/jpeg'
# note.resources = [image]
# 
# # 音楽ファイルの追加
# audio_data = open('path/to/your/audio.mp3', 'rb').read()
# audio = Types.Resource()
# audio.data = Types.Data()
# audio.data.size = len(audio_data)
# audio.data.bodyHash = hashlib.md5(audio_data).digest()
# audio.data.body = audio_data
# audio.mime = 'audio/mpeg'
# note.resources.append(audio)
# 
# # PDFファイルの追加
# pdf_data = open('path/to/your/document.pdf', 'rb').read()
# pdf = Types.Resource()
# pdf.data = Types.Data()
# pdf.data.size = len(pdf_data)
# pdf.data.bodyHash = hashlib.md5(pdf_data).digest()
# pdf.data.body = pdf_data
# pdf.mime = 'application/pdf'
# note.resources.append(pdf)

# 位置情報の設定
note.attributes = Types.NoteAttributes()
note.attributes.latitude = 37.7749
note.attributes.longitude = -122.4194
note.attributes.altitude = 10

# ノートの作成
created_note = note_store.createNote(note)
print("Successfully created a new note with GUID: ", created_note.guid)
