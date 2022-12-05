import gleam/int
import gleam/io
import gleam/list
import gleam/map.{Map}
import gleam/string
import util.{read_lines}

pub type State =
  Map(Int, List(String))

fn get_initial_state() -> State {
  map.from_list([
    #(1, ["F", "R", "W"]),
    #(2, ["P", "W", "V", "D", "C", "M", "H", "T"]),
    #(3, ["L", "N", "Z", "M", "P"]),
    #(4, ["R", "H", "C", "J"]),
    #(5, ["B", "T", "Q", "H", "G", "P", "C"]),
    #(6, ["Z", "F", "L", "W", "C", "G"]),
    #(7, ["C", "G", "J", "Z", "Q", "L", "V", "W"]),
    #(8, ["C", "V", "T", "W", "F", "R", "N", "P"]),
    #(9, ["V", "S", "R", "G", "H", "W", "J"]),
  ])
}

pub type Action {
  Action(count: Int, from: Int, to: Int)
}

fn get_action(line: String) -> Action {
  assert ["move", count, "from", from, "to", to] = string.split(line, on: " ")
  assert Ok(count) = int.parse(count)
  assert Ok(from) = int.parse(from)
  assert Ok(to) = int.parse(to)
  Action(count, from, to)
}

fn perform_action(state: State, action: Action) -> State {
  assert Ok([to_move, ..rest]) = map.get(state, action.from)
  assert Ok(dest) = map.get(state, action.to)

  state
  |> map.insert(action.to, [to_move, ..dest])
  |> map.insert(action.from, rest)
}

fn get_actions() -> List(Action) {
  assert Ok(lines) = read_lines("src/days/five.txt")

  list.map(lines, get_action)
}

pub fn part_one() {
  let actions = get_actions()
  let state = get_initial_state()
  let final_state = list.fold(actions, state, perform_action)

  let top_letters =
    final_state
    |> map.values
    |> list.filter_map(list.at(_, 0))
    |> string.join(with: "")

  io.debug(#("the top letters are", top_letters))

  Nil
}
