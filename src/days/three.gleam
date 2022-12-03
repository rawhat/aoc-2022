import gleam/int
import gleam/io
import gleam/list
import gleam/set
import gleam/string
import util.{read_lines}

type Rucksack {
  Rucksack(left: List(String), right: List(String))
}

fn score_value(item: String) -> Int {
  case <<item:utf8>> {
    <<value:int>> if value > 96 -> value - 96
    <<value:int>> -> value - 38
  }
}

fn get_chars_from_lines() -> List(List(String)) {
  assert Ok(lines) = read_lines("src/days/three.txt")
  list.map(lines, string.to_graphemes)
}

fn get_rucksacks() -> List(Rucksack) {
  get_chars_from_lines()
  |> list.map(fn(chars) {
    let size = list.length(chars)
    let #(left, right) = list.split(chars, at: size / 2)
    Rucksack(left, right)
  })
}

fn find_duplicate(sack: Rucksack) -> String {
  let left = set.from_list(sack.left)
  let right = set.from_list(sack.right)

  assert Ok(duplicate) =
    set.intersection(left, right)
    |> set.to_list
    |> list.at(0)

  duplicate
}

pub fn part_one() {
  get_rucksacks()
  |> list.map(find_duplicate)
  |> list.map(score_value)
  |> int.sum
  |> fn(value) { io.debug(#("sum of items in both", value)) }

  Nil
}

pub fn part_two() {
  get_chars_from_lines()
  |> list.map(set.from_list)
  |> list.sized_chunk(3)
  |> list.map(fn(group) {
    assert [one, two, three] = group
    assert Ok(badge) =
      set.intersection(one, two)
      |> set.intersection(three)
      |> set.to_list
      |> list.at(0)
    badge
  })
  |> list.map(score_value)
  |> int.sum
  |> fn(value) { io.debug(#("sum of badge values is", value)) }

  Nil
}
