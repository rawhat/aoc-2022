import gleam/function
import gleam/int
import gleam/io
import gleam/list
import gleam/set
import gleam/string
import util

pub type Direction {
  Up
  Right
  Down
  Left
}

pub type Position {
  Position(x: Int, y: Int)
}

fn is_adjacent(a: Position, b: Position) -> Bool {
  let x_diff = int.absolute_value(a.x - b.x)
  let y_diff = int.absolute_value(a.y - b.y)

  x_diff <= 1 && y_diff <= 1
}

fn position_offset(from: Position, offset: Position) -> Position {
  Position(x: from.x + offset.x, y: from.y + offset.y)
}

pub type Rope {
  Rope(head: Position, tails: List(Position))
}

fn parse_input(input: String) -> List(Direction) {
  input
  |> string.trim
  |> string.split(on: "\n")
  |> list.map(string.split(_, on: " "))
  |> list.flat_map(fn(pair) {
    assert [direction, count] = pair
    assert Ok(count) = int.parse(count)

    let direction = case direction {
      "U" -> Up
      "D" -> Down
      "L" -> Left
      "R" -> Right
    }

    list.range(0, count - 1)
    |> list.map(fn(_) { direction })
  })
}

fn is_next_to(a: Position, b: Position) -> Bool {
  let x_diff = int.absolute_value(a.x - b.x)
  let y_diff = int.absolute_value(a.y - b.y)
  case x_diff, y_diff {
    0, 0 | 1, 0 | 0, 1 | 1, 1 -> True
    _, _ -> False
  }
}

fn get_surrounding_positions(position: Position) -> List(Position) {
  // doing this manually for preference
  [#(-1, 0), #(0, 1), #(1, 0), #(0, -1), #(-1, -1), #(1, 1), #(-1, 1), #(1, -1)]
  |> list.map(fn(pair) { Position(pair.0, pair.1) })
  |> list.map(position_offset(position, _))
}

fn find_adjacent_position(head: Position, tail: Position) -> Position {
  case is_next_to(head, tail) {
    True -> tail
    False -> {
      let candidate_positions = get_surrounding_positions(head)
      assert Ok(adjacent) = list.find(candidate_positions, is_next_to(tail, _))
      adjacent
    }
  }
}

pub fn move_knot(head: Position, knot: Position) -> Position {
  case is_adjacent(head, knot) {
    True -> knot
    False -> find_adjacent_position(head, knot)
  }
}

pub fn part_one() {
  assert Ok(input) = util.read_file("src/days/nine.txt")

  let moves = parse_input(input)

  assert #(unique_tail_positions, _rope) =
    list.fold(
      moves,
      #(set.new(), Rope(Position(0, 0), [Position(0, 0)])),
      fn(game, move) {
        assert #(visited, Rope(head, tail)) = game
        assert [tail] = tail

        let new_head = case move {
          Up -> Position(head.x, head.y + 1)
          Down -> Position(head.x, head.y - 1)
          Left -> Position(head.x - 1, head.y)
          Right -> Position(head.x + 1, head.y)
        }

        let new_tail = move_knot(new_head, tail)
        let new_visited = set.insert(visited, new_tail)

        #(new_visited, Rope(new_head, [new_tail]))
      },
    )

  io.debug(#(
    "the tail visited",
    set.size(unique_tail_positions),
    "unique positions",
  ))

  Nil
}

pub fn part_two() {
  assert Ok(input) = util.read_file("src/days/nine.txt")

  let moves = parse_input(input)

  let initial_state = #(
    set.new(),
    Rope(
      Position(0, 0),
      list.range(0, 8)
      |> list.map(function.constant(Position(0, 0))),
    ),
  )

  assert #(last_tail_positions, _rope) =
    list.fold(
      moves,
      initial_state,
      fn(state, move) {
        assert #(last_visited, Rope(head, knots)) = state

        let new_head = case move {
          Up -> Position(head.x, head.y + 1)
          Down -> Position(head.x, head.y - 1)
          Left -> Position(head.x - 1, head.y)
          Right -> Position(head.x + 1, head.y)
        }

        assert #(_knot, [last_knot, ..other_knots]) =
          list.fold(
            knots,
            #(new_head, []),
            fn(state, next) {
              assert #(prev, knots) = state

              let new_knot = move_knot(prev, next)
              #(new_knot, [new_knot, ..knots])
            },
          )

        let new_visited = set.insert(last_visited, last_knot)
        let new_rope = Rope(new_head, list.reverse([last_knot, ..other_knots]))

        #(new_visited, new_rope)
      },
    )

  io.debug(#(
    "the last knot touched",
    set.size(last_tail_positions),
    "unique positions",
  ))

  Nil
}
