import gleam/dynamic.{field, int, list, string}
import gleam/io
import gleam/json
import gleam/result

// import gleam/json.{int, list, null, object, string}
import gleam/list
import simplifile

pub fn main() {
  // io.println("Hello from gleamtest!")
  let path = "test.json"
  let contents = simplifile.read(path)
  // case contents {
  //   Ok(c) -> c
  //   Error(_) -> "error"
  // }
  // |> io.println()
  // io.println(contents)
  let jny =
    result.unwrap(contents, "")
    |> journey_from_json()
  case jny {
    Ok(j) ->
      j
      |> cat_to_json
    Error(_) -> ""
  }
  |> io.println()
  // io.println(cat_to_json(jny))
}

pub fn journey_from_json(
  json_string: String,
) -> Result(Journey, json.DecodeError) {
  let cat_decoder =
    dynamic.decode3(
      Journey,
      field("id", of: string),
      field("date_modified", of: int),
      field("text", of: string),
    )

  json.decode(from: json_string, using: cat_decoder)
}

pub fn cat_to_json(jny: Journey) -> String {
  json.object([
    #("id", json.string(jny.id)),
    #("date", json.int(jny.date)),
    #("text", json.string(jny.text)),
  ])
  |> json.to_string
}

pub type Journey {
  Journey(id: String, date: Int, text: String)
}
