import gleam/int
import gleam/io
import gleam/list
import gleam/string
import util.{read_lines}

pub type Assignment {
  Assignment(lower: Int, upper: Int)
}

fn parse_assignment(value: String) -> Assignment {
  assert [start, end] = string.split(value, on: "-")

  assert Ok(start) = int.parse(start)
  assert Ok(end) = int.parse(end)

  Assignment(start, end)
}

fn is_contained(a: Assignment, b: Assignment) -> Bool {
  let a_inside = a.lower >= b.lower && a.upper <= b.upper
  let b_inside = b.lower >= a.lower && b.upper <= a.upper

  a_inside || b_inside
}

fn is_overlapping(a: Assignment, b: Assignment) -> Bool {
  a.lower >= b.lower && a.lower <= b.upper || b.lower >= a.lower && b.lower <= a.upper
}

fn get_assignments() -> List(#(Assignment, Assignment)) {
  assert Ok(lines) = read_lines("src/days/four.txt")

  lines
  |> list.map(string.split(_, on: ","))
  |> list.map(fn(pairs) {
    assert [left, right] = pairs

    #(parse_assignment(left), parse_assignment(right))
  })
}

pub fn part_one() {
  get_assignments()
  |> list.filter(fn(pair) { is_contained(pair.0, pair.1) })
  |> list.length
  |> fn(count) { io.debug(#("there are", count, "containing ranges")) }

  Nil
}

pub fn part_two() {
  get_assignments()
  |> list.filter(fn(pair) { is_overlapping(pair.0, pair.1) })
  |> list.length
  |> fn(count) { io.debug(#("there are", count, "overlapping ranges")) }

  Nil
}
