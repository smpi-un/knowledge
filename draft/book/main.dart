import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart' as dotenv;

Future<void> main(List<String> arguments) async {
  if (arguments.isEmpty) {
    print('ファイルパスを指定してください。');
    return;
  }

  final filePath = arguments[0];
  final file = File(filePath);

  if (!await file.exists()) {
    print('指定されたファイルが存在しません。');
    return;
  }

  final isbnPattern = RegExp(r'\b(?:ISBN(?:-13)?:? )?((?:978|979)[\d\- ]{10,17})\b');
  final env = dotenv.DotEnv(includePlatformEnvironment: true)..load();
  final apiKey = env['GOOGLE_BOOKS_API_KEY'] ?? Platform.environment['GOOGLE_BOOKS_API_KEY'];
  //final apiKey = "";
  if (apiKey == null) {
    print('環境変数 GOOGLE_BOOKS_API_KEY が設定されていません。');
    return;
  }

  final successLog = File('/home/smpiun/success.log');
  final lines = await file.readAsLines();
  for (var line in lines) {
    print(line);
    final matches = isbnPattern.allMatches(line);
    for (var match in matches) {
      final isbn = match.group(1)?.replaceAll(RegExp(r'[\- ]'), '');
      if (isbn != null) {
        try {
          print(isbn);
          final bookInfo = await fetchBookInfo(isbn, apiKey);
          if (bookInfo != null) {
            print(bookInfo);
            printBookInfo(bookInfo);
            await successLog.writeAsString('$isbn\n', mode: FileMode.append);
          }
        } catch (e) {
          print('ISBN: $isbn の情報取得に失敗しました。');
        }
      }
    }
  }
}

Future<Map<String, dynamic>?> fetchBookInfo(String isbn, String apiKey) async {
  final url = 'https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn&key=$apiKey';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['totalItems'] > 0) {
      return data['items'][0]['volumeInfo'];
    }else{
      print("nnnn");
    }
  }
  print(response.statusCode);
  return null;
}

void printBookInfo(Map<String, dynamic> info) {
  final title = info['title'];
  final authors = (info['authors'] as List<dynamic>?)?.join(', ') ?? '不明';
  final publishedDate = formatPublishedDate(info['publishedDate'] ?? '不明');

  print('タイトル: $title');
  print('著者: $authors');
  print('発行日: $publishedDate');
}

String formatPublishedDate(String date) {
  try {
    final parsedDate = DateTime.parse(date);
    final weekdays = ['月', '火', '水', '木', '金', '土', '日'];
    final formattedDate = '${parsedDate.year}年${parsedDate.month}月${parsedDate.day}日(${weekdays[parsedDate.weekday - 1]})';
    return formattedDate;
  } catch (e) {
    return '不明';
  }
}
