---
title: "attern Matching比較メモ" # 記事のタイトル
emoji: "🧩" # アイキャッチとして使われる絵文字（1文字だけ）
type: "tech" # tech: 技術記事 / idea: アイデア記事
topics: ["pattern matching", "python", "nim"] # タグ。["markdown", "rust", "aws"]のように指定する
published: false # 公開設定（falseにすると下書き）
---

# attern Matching比較メモ

JSONのパターンマッチングをやりたい。

## サンプルデータ
サンプルのJSONはClaudeさんに作ってもらう。

> WEB APIの結果となるJsonを定義したい。
> 以下の条件でサンプルを作って。
> - 成功か失敗かを判断できる項目がある。
> - 成功した場合は、データのリストを返す。データの1つ1つには音楽または本の情報が設定されている。
> - 音楽の場合は、タイトル・作曲者・出版社・曲の長さ・音楽のジャンルをもつ。本の場合は、タイトル・著者・出版社・ページ数・本のジャンル・言語をもつ。
> - 失敗した場合は原因を示すコードとメッセージを含む。

### 成功時
```json
{
 "success": true,
 "data": [
   {
     "type": "music",
     "title": "Bohemian Rhapsody",
     "composer": "Freddie Mercury",
     "publisher": "EMI Records",
     "duration": "5:55",
     "genre": "Rock"
   },
   {
     "type": "book",
     "title": "To Kill a Mockingbird",
     "author": "Harper Lee",
     "publisher": "J. B. Lippincott & Co.",
     "pages": 324,
     "genre": "Southern Gothic",
     "language": "English"
   },
   {
     "type": "music",
     "title": "Stairway to Heaven",
     "composer": "Jimmy Page, Robert Plant",
     "publisher": "Atlantic Records",
     "duration": "8:02",
     "genre": "Rock"
   }
 ]
}
```
結果:
```
Freddie Mercury
Harper Lee
Jimmy Page, Robert Plant
```

### 失敗時
```json
{
  "success": false,
  "error": {
    "code": 404,
    "message": "Data not found"
  }
}
```
実行結果:
```
Data not found
```

# パターンマッチングのコード

## Python 3.12

```python
import json
if True:
    json_str = '''{
    "success": true,
    "data": [
      {
        "type": "music",
        "title": "Bohemian Rhapsody",
        "composer": "Freddie Mercury",
        "publisher": "EMI Records",
        "duration": "5:55",
        "genre": "Rock"
      },
      {
        "type": "book",
        "title": "To Kill a Mockingbird",
        "author": "Harper Lee",
        "publisher": "J. B. Lippincott & Co.",
        "pages": 324,
        "genre": "Southern Gothic",
        "language": "English"
      },
      {
        "type": "music",
        "title": "Stairway to Heaven",
        "composer": "Jimmy Page, Robert Plant",
        "publisher": "Atlantic Records",
        "duration": "8:02",
        "genre": "Rock"
      }
    ]
    }
    '''
else:
    json_str = '''{
    {
      "success": false,
      "error": {
        "code": 404,
        "message": "Data not found"
      }
    }
    '''

match json.loads(json_str):
  case {'success': True, 'data': data}:
    for item in data:
        match item:
            case {'type': 'music', 'composer': composer}:
                print(composer)
            case {'type': 'book', 'author': author}:
                print(author)
  case {'success': False, 'error': {'message': message}}:
    print(message)
```

## Nim
```nim
import json
import fusion/matching

when true:
  let jsonStr = """
  {
    "success": true,
    "data": [
      {
        "type": "music",
        "title": "Bohemian Rhapsody",
        "composer": "Freddie Mercury",
        "publisher": "EMI Records",
        "duration": "5:55",
        "genre": "Rock"
      },
      {
        "type": "book",
        "title": "To Kill a Mockingbird",
        "author": "Harper Lee",
        "publisher": "J. B. Lippincott & Co.",
        "pages": 324,
        "genre": "Southern Gothic",
        "language": "English"
      },
      {
        "type": "music",
        "title": "Stairway to Heaven",
        "composer": "Jimmy Page, Robert Plant",
        "publisher": "Atlantic Records",
        "duration": "8:02",
        "genre": "Rock"
      }
    ]
  }
  """
else:
  let jsonStr = """
  {
    "success": false,
    "error": {
      "code": 404,
      "message": "Data not found"
    }
  }
  """

case parseJson(jsonStr):
  of { "success" : JBool(bval: true), "data": JArray(elems: @data)}:
    for item in data:
      case item:
        of {"type": JString(str: "music"), "composer": JString(str: @composer)}:
          echo composer
        of {"type": JString(str: "book"), "author": JString(str: @author)}:
          echo author
  of { "success" : JBool(bval: false), "error": {"message": JString(str: @message)}}:
    echo message
  else:
    echo "unknown"
```

## Dart
```dart
import 'dart:convert';

void main() {
  final jsonStr = '''{
    "success": true,
    "data": [
      {
        "type": "music",
        "title": "Bohemian Rhapsody",
        "composer": "Freddie Mercury",
        "publisher": "EMI Records",
        "duration": "5:55",
        "genre": "Rock"
      },
      {
        "type": "book",
        "title": "To Kill a Mockingbird",
        "author": "Harper Lee",
        "publisher": "J. B. Lippincott & Co.",
        "pages": 324,
        "genre": "Southern Gothic",
        "language": "English"
      },
      {
        "type": "music",
        "title": "Stairway to Heaven",
        "composer": "Jimmy Page, Robert Plant",
        "publisher": "Atlantic Records",
        "duration": "8:02",
        "genre": "Rock"
      }
    ]
  }''';
//   final jsonStr = '''{
//     "success": false,
//     "error": {
//       "code": 404,
//       "message": "Data not found"
//     }
//   }''';

  final jsonData = jsonDecode(jsonStr);

  switch(jsonData){
    case {'success': true, "data": final data}:
      for(final item in data){
        switch(item) {
          case {"type": "book", "author": final author}:
            print(author);
          case {"type": "music", "composer": final composer}:
            print(composer);
        };
      }
    case {'success': false, 'error': {'message': final message}}:
      print(message);
    default:
      print('');
  };

}
```