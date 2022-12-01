import gleam/int
import gleam/io
import gleam/list
import gleam/string
import util.{read_file}

fn get_sorted_calorie_counts() -> List(Int) {
  assert Ok(input) = read_file("src/days/one.txt")

  let calories_to_list = fn(entry: String) -> List(Int) {
    entry
    |> string.split(on: "\n")
    |> list.filter_map(int.parse)
  }

  input
  |> string.split(on: "\n\n")
  |> list.map(calories_to_list)
  |> list.map(int.sum)
  |> list.sort(int.compare)
  |> list.reverse
}

pub fn part_one() {
  assert [max, ..] = get_sorted_calorie_counts()

  io.debug(#("max calorie count is", max))

  Nil
}

pub fn part_two() {
  let sum =
    get_sorted_calorie_counts()
    |> list.take(3)
    |> int.sum

  io.debug(#("sum of top three calorie counts is", sum))

  Nil
}
