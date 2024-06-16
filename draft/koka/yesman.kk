import std/os/readline


fun question() 
  val answer = input("Do you like Udon?")
  answer.println()
  val answer = input("海に行きませんか？")
  answer.println()
  val answer = input("戦力は破棄すべきか？")
  answer.println()

effect qq
  ctl input( msg : string ) : bool


pub fun main()
  mainShijimachi()

pub fun mainYesman()
  with
    ctl input(message)
      message.println()
      resume(True)
  question()
      

pub fun mainNoman()
  with
    ctl input(message)
      message.println()
      resume(False)
  question()
      

pub fun mainShijimachi()
  with
    ctl input(message)
      (message ++ " [Yn]").println()
      val res = readline()

      resume(res == "Y")
  question()
      