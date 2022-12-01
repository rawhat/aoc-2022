import gleam/int
import gleam/io
import gleam/list
import gleam/string
import util.{read_file}

fn get_sorted_calorie_counts() -> List(Int) {
  assert Ok(input) = read_file("src/days/one.txt")
  let values = string.split(input, on: "\n\n")

  let calories_to_list = fn(entry: String) -> List(Int) {
    entry
    |> string.split(on: "\n")
    |> list.filter_map(int.parse)
  }

  values
  |> list.map(calories_to_list)
  |> list.map(list.fold(_, 0, fn(acc, value) { acc + value }))
  |> list.sort(int.compare)
  |> list.reverse
}

pub fn part_one() {
  assert [max, ..] = get_sorted_calorie_counts()

  io.debug(#("max calorie count is", max))

  Nil
}

pub fn part_two() {
  assert [first, second, third, ..] = get_sorted_calorie_counts()

  io.debug(#("sum of top three calorie counts is", first + second + third))

  Nil
}
