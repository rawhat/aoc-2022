import gleam/io
import gleam/list
import gleam/pair
import gleam/result
import gleam/string
import util.{read_file}

fn get_stream() -> List(String) {
  assert Ok(input) = read_file("src/days/six.txt")
  input
  |> string.trim
  |> string.to_graphemes
}

fn find_unique_sequence_index(length: Int) -> Int {
  get_stream()
  |> list.window(by: length)
  |> list.index_map(fn(index, group) { #(index, group) })
  |> list.find(fn(value) {
    assert #(_index, codes) = value
    list.unique(codes) == codes
  })
  |> result.map(pair.first)
  |> result.map(fn(index) { index + length })
  |> result.unwrap(-1)
}

pub fn part_one() {
  let index = find_unique_sequence_index(4)
  io.debug(#("it took", index, "chars to find the marker"))

  Nil
}

pub fn part_two() {
  let index = find_unique_sequence_index(14)
  io.debug(#("it took", index, "chars to find the message"))

  Nil
}
