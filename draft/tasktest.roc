app [main] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.10.0/vNe6s9hWzoTZtFmNkvEICPErI9ptji_ySjicO6CkucY.tar.br",
    json: "https://github.com/lukewilliamboswell/roc-json/releases/download/0.10.0/KbIfTNbxShRX1A1FgXei1SpO5Jn8sgP6HP6PXbi-xyA.tar.br",
    json08: "https://github.com/lukewilliamboswell/roc-json/releases/download/0.8.0/BlWJJh_ouV7c_IwvecYpgpR3jOCzVO-oyk-7ISdl2S4.tar.br",

}

import pf.Stdout
import pf.Stderr
import pf.Arg
import pf.Env
import pf.Http
import pf.Dir
import pf.Utc
import pf.File
import pf.Path exposing [Path]
import pf.Task exposing [Task]
import json.Json 
import Decode exposing [fromBytesPartial]
import Decode
import Encode
import json08.Core exposing [jsonWithOptions]
import json.OptionOrNull exposing [OptionOrNull]
import json.Json





getWikipedia = \url -> 
    { Http.defaultRequest & url: url }
    |> Http.send


# listJsonInDir: Str -> Task (List Path) [DirErr Err]
listJsonInDir = \path -> 
  if path |> Path.isFile! then
    Task.ok [path]
  else if path |> Path.isDir! then
    paths = Dir.list! path
    recPaths = paths |> List.map listJsonInDir |> Task.seq!
    flattenPaths = recPaths |> List.join
    flattenPaths |> Task.ok
  else
    [] |> Task.ok
  
# Task to read the first CLI arg (= Str)
readFirstArgT : Task.Task Str [ZeroArgsGiven]_
readFirstArgT =
    # read all command line arguments
    args = Arg.list!

    # get the second argument, the first is the executable's path
    List.get args 1 |> Result.mapErr (\_ -> ZeroArgsGiven) |> Task.fromResult

incrementedNumbers =
    [1, 2, 3]
        |> List.reverse
        |> List.map \num ->
            z = num * num
            z + 1


main =
  # firstArg = "."
  args = Arg.list!
  args |> Str.joinWith " " |> Stdout.line!
  firstArg = args |> List.get 1 |> Result.withDefault "/home/smpiun/Documents/Journey/journey-1681648736745_DL"
  dirList = firstArg |> Path.fromStr |> listJsonInDir!
  Task.forEach dirList \path->
    if path |> Path.display |> Str.endsWith ".json" then
      # pathStr = (path |> Path.display)
      jsonContent <- path |> File.readUtf8 |> Task.await
      decodedValue = jsonContent |> parseJourneyGoogleCloudJson10
      text = decodedValue |> Result.map (\y -> y.text) |> Result.withDefault ""
      Stdout.line text
    else
      Task.ok {}
main3 =
  # firstArg = "."
  args = Arg.list!
  args |> Str.joinWith " " |> Stdout.line!
  firstArg = args |> List.get 1 |> Result.withDefault "/home/smpiun/Documents/Journey/journey-1681648736745_DL"
  dirList = firstArg |> Path.fromStr |> listJsonInDir!
  jsonFilePaths : List Path
  jsonFilePaths = dirList |> List.keepIf (\x -> x |> Path.display |> Str.endsWith ".json")
  jsonFilePaths |> List.map Path.display |>  Str.joinWith "\n" |> Stdout.line!
  jsonContentsRes : List (Result Str _)
  jsonContents = jsonFilePaths |> readFiles!
  decodedValues = jsonContents |> List.map parseJourneyGoogleCloudJson10
  decodedValues |> List.map (\x -> x |> Result.map (\y -> y.text) |> Result.withDefault "") |> Str.joinWith "\n" |> Stdout.line! 


readFiles : List Path -> Task (List Str) *
readFiles = \paths ->
  readTask = paths |> List.map (\path -> path |> File.readUtf8 |> Task.result)
  readRes = readTask |> Task.seq!
  jsonContents = readRes |> List.keepOks (\x -> x)
  Task.ok jsonContents
  

# json10ライブラリを使ったJsonパース
parseJourneyGoogleCloudJson10: Str -> Result JourneyGoogleDrive _
parseJourneyGoogleCloudJson10 = \jsonStr ->
  jsonU8 = jsonStr |> Str.replaceEach "1.7976931348623157E+308" "null" |> Str.toUtf8 
  result : Result JourneyGoogleDrive _
  result = jsonU8 |> Decode.fromBytes (Json.utf8With { fieldNameMapping: SnakeCase })
  result |> Result.onErr (\reason -> Err (JourneyGoogleDriveParseError reason))

# json08ライブラリを使ったJsonパース
parseJourneyGoogleCloudJson08: Str -> Result JourneyGoogleDrive _
parseJourneyGoogleCloudJson08 = \jsonStr ->
  jsonU8 = jsonStr |> Str.replaceEach "1.7976931348623157E+308" "null" |> Str.toUtf8 
  decoder = jsonWithOptions { fieldNameMapping: SnakeCase }
  decoded : DecodeResult JourneyGoogleDrive
  decoded = fromBytesPartial jsonU8 decoder
  decoded.result |> Result.onErr (\reason -> Err (JourneyGoogleDriveParseError reason))


JourneyGoogleDrive : {
    id: Str,
    dateModified: I64,
    dateJournal: I64,
    timezone: Str,
    text: Str,
    previewText: Str,
    mood: I64,
    lat: OptionOrNull F64,
    lon: OptionOrNull F64,
    address: Str,
    label: Str,
    folder: Str,
    sentiment: I64,
    favourite: Bool,
    musicTitle: Str,
    musicArtist: Str,
    photos: List Str,
    weather: {
      id: I64,
      degreeC: OptionOrNull F64,
      description: Str,
      icon: Str,
      place: Str,
    },
    tags: List Str,
    # type: Str,
    # wasureta: OptionOrNull Str,
}

# {"text":"<p dir=\"auto\">頭痛がさ。<\/p>","date_modified":1679867083784,"date_journal":1679867075567,"id":"1679867075567-3fe8fd2121c01e26","preview_text":"","address":"日本、〒939-8055 富山県富山市下堀３１−９","music_artist":"","music_title":"","lat":36.6611096,"lon":137.2285631,"mood":1,"label":"","folder":"","sentiment":0,"timezone":"Asia\/Tokyo","favourite":false,"type":"html","linked_account_id":"drive-25842cc29fffaebef24fd9148d5c3114b435bce5d2ed83c818e5f4a5fd8cf2e8","weather":{"id":0,"degree_c":7,"description":"Light rain","icon":"10d","place":"Toyama"},"photos":[],"tags":[]}