app [main] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.10.0/vNe6s9hWzoTZtFmNkvEICPErI9ptji_ySjicO6CkucY.tar.br",
    json: "https://github.com/lukewilliamboswell/roc-json/releases/download/0.10.0/KbIfTNbxShRX1A1FgXei1SpO5Jn8sgP6HP6PXbi-xyA.tar.br",
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



getWikipedia = \url -> 
    { Http.defaultRequest & url: url }
    |> Http.send


# listJsonInDir: Str -> Task (List Path) [DirErr Err]
listJsonInDir = \path -> 
  if path |> Path.isFile! then
    Task.ok [path]
  else if path |> Path.isDir! then
    paths = Dir.list path!
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


main =
  # firstArg = (Arg.list!) |> List.get 1 |> Task.fromResult!
  firstArg = "."
  dirList = firstArg |> Path.fromStr |> listJsonInDir!
  # dirList |> List.map Path.display |> Str.joinWith "\n" |> Stdout.line!
  jsonFilePaths = dirList |> List.keepIf (\x -> x |> Path.display |> Str.endsWith ".json")
  jsonFilePaths |> List.map Path.display |>  Str.joinWith "\n" |> Stdout.line!
  jsonContents = jsonFilePaths |> List.map File.readUtf8 |> Task.seq!
  result : Result JourneyGoogleDrive _
  jsonStr : Str
  jsonStr = jsonContents |> List.first |> Task.fromResult!
  jsonU8 = jsonStr |> Str.toUtf8 
  res = jsonU8 |> Decode.fromBytes Json.utf8 |> Task.fromResult!
  res.text |> Stdout.line!

main2 =
  url = "https://www.roc-lang.org/packages/basic-cli/Http"
  getRes <- getWikipedia url |> Task.attempt
  when getRes is
    Ok resp -> resp |> Http.handleStringResponse |> Result.withDefault "default" |> Stdout.line!
    Err _ -> Stdout.line! "err"


JourneyGoogleDrive : {
    text: Str,
    dateModified: I64,
    dateJournal: I64,
    id: Str,
    previewText: Str,
    address: Str,
    musicArtist: Str,
}

# {"text":"<p dir=\"auto\">頭痛がさ。<\/p>","date_modified":1679867083784,"date_journal":1679867075567,"id":"1679867075567-3fe8fd2121c01e26","preview_text":"","address":"日本、〒939-8055 富山県富山市下堀３１−９","music_artist":"","music_title":"","lat":36.6611096,"lon":137.2285631,"mood":1,"label":"","folder":"","sentiment":0,"timezone":"Asia\/Tokyo","favourite":false,"type":"html","linked_account_id":"drive-25842cc29fffaebef24fd9148d5c3114b435bce5d2ed83c818e5f4a5fd8cf2e8","weather":{"id":0,"degree_c":7,"description":"Light rain","icon":"10d","place":"Toyama"},"photos":[],"tags":[]}