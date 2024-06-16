# Run with `roc ./examples/CommandLineArgs/main.roc -- examples/CommandLineArgs/input.txt`
app [main] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.10.0/vNe6s9hWzoTZtFmNkvEICPErI9ptji_ySjicO6CkucY.tar.br",
}

import pf.Stdout
import pf.File
import pf.Path
import pf.Task
import pf.Arg

main =
    a <- funsugarTest1 |> Task.await
    a |> Str.joinWith "," |> Stdout.line!
    # Stdout.line! (funsugarTest2 |> Task.await |> Str.joinWith ",")
    finalTask =
        # try to read the first command line argument
        readFirstArgT!
        # pathArg 
    finalTask |> Stdout.line #Task.onErr handleErr |> Stdout.line

# handleErr : Error -> Task {} *


    # finalResult <- Task.attempt finalTask

    # when finalResult is
    #     Err ZeroArgsGiven ->
    #         Task.err (Exit 1 "Error ZeroArgsGiven:\n\tI expected one argument, but I got none.\n\tRun the app like this: `roc command-line-args.roc -- path/to/input.txt`")

    #     Err (ReadFileErr errMsg) ->
    #         indentedErrMsg = indentLines errMsg

    #         Task.err (Exit 1 "Error ReadFileErr:\n$(indentedErrMsg)")

    #     Ok fileContentStr ->
    #         Stdout.line "file content: $(fileContentStr)"

# Task to read the first CLI arg (= Str)
readFirstArgT : Task.Task Str [ZeroArgsGiven]_
readFirstArgT =
    # read all command line arguments
    args = Arg.list!

    # get the second argument, the first is the executable's path
    List.get args 1 |> Result.mapErr (\_ -> ZeroArgsGiven) |> Task.fromResult


# indent all lines in a Str with a single tab
indentLines : Str -> Str
indentLines = \inputStr ->
    Str.split inputStr "\n"
    |> List.map (\line -> Str.concat "\t" line)
    |> Str.joinWith "\n"


funsugarTest1 = 
  arr = [1,2,3]
  res = arr |> List.map \itm ->
    itm * 2 |> Num.toStr
  Task.ok res
  

funsugarTest2 = 
  arr = [1,2,3]
  itm <- arr |> List.map
  res = itm * 2 |> Num.toStr
  Task.ok res
