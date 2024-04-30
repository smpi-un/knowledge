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
