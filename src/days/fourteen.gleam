import gleam/int
import gleam/io
import gleam/iterator.{Done, Next}
import gleam/list
import gleam/result
import gleam/string
import grid.{Grid, Position}
import util

pub type Cell {
  Wall
  Sand
}

pub fn generate_walls(input: String) -> Grid(Cell) {
  input
  |> string.split(on: "\n")
  |> list.flat_map(fn(points) {
    let points = string.split(points, on: " -> ")
    points
    |> list.window(2)
    |> list.flat_map(fn(points) {
      assert [start, end] = points
      assert [start_x, start_y] = string.split(start, on: ",")
      assert [end_x, end_y] = string.split(end, on: ",")
      assert Ok(start_x) = int.parse(start_x)
      assert Ok(start_y) = int.parse(start_y)
      assert Ok(end_x) = int.parse(end_x)
      assert Ok(end_y) = int.parse(end_y)

      iterator.range(start_x, end_x)
      |> iterator.flat_map(fn(x) {
        iterator.range(start_y, end_y)
        |> iterator.map(fn(y) { Position(x, y) })
      })
      |> iterator.to_list
    })
  })
  |> list.map(fn(pos) { #(pos, Wall) })
  |> iterator.from_list
  |> grid.from_iterator
}

pub type SandPosition {
  Overflow
  New(Position)
}

pub fn do_drop_sand(cavern: Grid(Cell), candidate: Position) -> SandPosition {
  let rows = grid.row_count(cavern)

  case candidate.y > rows {
    True -> Overflow
    False -> {
      let below_position = Position(candidate.x, candidate.y + 1)
      let below_value = grid.get(cavern, below_position)
      let down_left_position = Position(candidate.x - 1, candidate.y + 1)
      let down_left_value = grid.get(cavern, down_left_position)
      let down_right_position = Position(candidate.x + 1, candidate.y + 1)
      let down_right_value = grid.get(cavern, down_right_position)
      case below_value, down_left_value, down_right_value {
        Ok(Wall), Error(_nil), _ | Ok(Sand), Error(_nil), _ ->
          do_drop_sand(cavern, down_left_position)
        Ok(Wall), Ok(_filled), Error(_nil) | Ok(Sand), Ok(_filled), Error(_nil) ->
          do_drop_sand(cavern, down_right_position)
        Ok(_filled), Ok(_filled), Ok(_filled) -> New(candidate)
        Error(_nil), _, _ -> do_drop_sand(cavern, below_position)
      }
    }
  }
}

pub fn drop_sand(cavern: Grid(Cell)) -> Result(Grid(Cell), Nil) {
  case do_drop_sand(cavern, Position(500, 0)) {
    Overflow -> Error(Nil)
    New(position) -> Ok(grid.set(cavern, position, Sand))
  }
}

pub fn part_one() {
  let input =
    "498,4 -> 498,6 -> 496,6
503,4 -> 502,4 -> 502,9 -> 494,9"

  assert Ok(input) = util.read_file("src/days/fourteen.txt")

  let cavern = generate_walls(input)

  let final_cavern =
    iterator.iterate(Ok(cavern), fn(cavern) { result.then(cavern, drop_sand) })
    |> iterator.take_while(result.is_ok)
    |> iterator.last

  assert Ok(Ok(cavern)) = final_cavern

  let sand_count = count_sand(cavern)
  io.debug(#(sand_count, "pieces of sand fell"))

  Nil
}

pub fn part_two() {
  assert Ok(input) = util.read_file("src/days/fourteen.txt")

  let cavern = generate_walls(input)
  let rows = grid.row_count(cavern)
  let cavern_with_floor =
    iterator.range(0, 1_000)
    |> iterator.fold(
      cavern,
      fn(cavern, column) { grid.set(cavern, Position(column, rows + 2), Wall) },
    )

  assert Ok(after_hole_plugged) =
    iterator.unfold(
      from: cavern_with_floor,
      with: fn(cavern) {
        case do_drop_sand(cavern, Position(500, 0)) {
          Overflow -> {
            io.println("we should not have gotten here")
            print_cavern(cavern)
            assert True = False
            Done
          }
          New(Position(500, 0)) -> Done
          New(position) -> {
            let new_cavern = grid.set(cavern, position, Sand)
            Next(new_cavern, new_cavern)
          }
        }
      },
    )
    |> iterator.last

  io.debug(#(
    "after the hole is plugged",
    // add one for the last piece
    count_sand(after_hole_plugged) + 1,
    "pieces of sand fell",
  ))

  Nil
}

fn count_sand(cavern: Grid(Cell)) -> Int {
  cavern
  |> grid.to_iterator
  |> iterator.filter(fn(entry) {
    let #(_position, value) = entry
    case value {
      Ok(Sand) -> True
      _ -> False
    }
  })
  |> iterator.to_list
  |> list.length
}

fn print_cavern(cavern: Grid(Cell)) -> Nil {
  io.println(grid.to_string(
    cavern,
    fn(entry) {
      case entry {
        Error(Nil) -> "."
        Ok(Sand) -> "o"
        Ok(Wall) -> "#"
      }
    },
  ))
}
