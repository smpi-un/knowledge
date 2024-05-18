
fun world()
  replace-all("hi there", "there", "world")  // returns "hi world"

pub fun main()
  val xyz = [3, 4, 6, 2, 0, 10]
  world().println()
  with ctl raise(msg) msg.println() 
  [3, 4, 6].map(fn(x)360.divide(x)).println()
  // [2, 0, 10].map(fn(x)360.divide(x)).println()

  with
    ctl morning(msg1)
      ("こんにちは、" ++ msg1).println()
    ctl evening(msg2)
      ("こんばんは、" ++ msg2).println()
  with
    ctl morning(msg1)
      ("Good morning, " ++ msg1).println()
      resume(10)
      resume(10)
      resume(10)
    ctl evening(msg2)
      ("Hello, " ++ msg2).println()
      resume(10)
  test(10)
  test(12)
  test(14)
  ()

// effect raise
//   ctl yield( s : string ) : bool
effect raise
  ctl raise( msg : string ) : a
effect oreeff
  ctl morning( msg : string ) : int
  ctl evening( msg : string ) : int

fun divide( x : int, y : int ) : raise int
  if y==0 then raise("div-by-zero") else x / y

fun test(x: int) : oreeff int
  if x <= 12 then morning("太郎") else evening("太郎")
  