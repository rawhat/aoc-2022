import gleam/function
import gleam/int
import gleam/io
import gleam/list
import gleam/map.{Map}
import gleam/string
import util

pub type Position {
  Position(row: Int, col: Int)
}

pub type GridItems =
  Map(Position, Int)

pub type Grid {
  Grid(items: GridItems, dimensions: Position)
}

fn parse_grid(input: String) -> Grid {
  let rows =
    input
    |> string.trim
    |> string.split(on: "\n")
  let row_count = list.length(rows)
  assert [first, ..] = rows
  let column_count = string.length(first)

  let items =
    rows
    |> list.index_map(fn(row_index, row) {
      row
      |> string.to_graphemes
      |> list.index_map(fn(column_index, value) {
        assert Ok(value) = int.parse(value)
        #(Position(row_index, column_index), value)
      })
    })
    |> list.flatten
    |> map.from_list

  Grid(items, Position(row_count, column_count))
}

fn is_visible(grid: Grid, at: Position) -> Bool {
  assert Ok(current) = map.get(grid.items, at)

  let can_see = fn(positions: List(Position)) {
    positions
    |> list.map(fn(position) {
      assert Ok(value) = map.get(grid.items, position)
      value
    })
    |> list.all(fn(value) { value < current })
  }

  let from_top =
    list.range(0, at.row - 1)
    |> list.map(fn(row) { Position(row, at.col) })
    |> can_see

  let from_bottom =
    list.range(at.row + 1, grid.dimensions.row - 1)
    |> list.map(fn(row) { Position(row, at.col) })
    |> can_see

  let from_left =
    list.range(0, at.col - 1)
    |> list.map(fn(col) { Position(at.row, col) })
    |> can_see

  let from_right =
    list.range(at.col + 1, grid.dimensions.col - 1)
    |> list.map(fn(col) { Position(at.row, col) })
    |> can_see

  from_top || from_bottom || from_left || from_right
}

fn get_scenic_score(grid: Grid, at: Position) -> Int {
  assert Ok(current) = map.get(grid.items, at)
  let tree_count = fn(positions: List(Position)) {
    let visible_trees =
      positions
      |> list.map(fn(position) {
        assert Ok(value) = map.get(grid.items, position)
        value
      })
      |> list.take_while(fn(value) { value < current })
      |> list.length

    case visible_trees == list.length(positions) {
      True -> visible_trees
      False -> visible_trees + 1
    }
  }

  let from_top =
    case at.row {
      0 -> []
      value -> list.range(0, value - 1)
    }
    |> list.map(fn(row) { Position(row, at.col) })
    |> list.reverse
    |> tree_count

  let from_bottom =
    case at.row == grid.dimensions.row - 1 {
      True -> []
      False -> list.range(at.row + 1, grid.dimensions.row - 1)
    }
    |> list.map(fn(row) { Position(row, at.col) })
    |> tree_count

  let from_left =
    case at.col {
      0 -> []
      value -> list.range(0, value - 1)
    }
    |> list.map(fn(col) { Position(at.row, col) })
    |> list.reverse
    |> tree_count

  let from_right =
    case at.col == grid.dimensions.col - 1 {
      True -> []
      False -> list.range(at.col + 1, grid.dimensions.col - 1)
    }
    |> list.map(fn(col) { Position(at.row, col) })
    |> tree_count

  from_top * from_bottom * from_left * from_right
}

pub fn part_one() {
  assert Ok(input) = util.read_file("src/days/eight.txt")
  let grid = parse_grid(input)

  let rows_to_test = list.range(1, grid.dimensions.row - 2)

  let columns_to_test = list.range(1, grid.dimensions.col - 2)

  let positions_to_test =
    rows_to_test
    |> list.flat_map(fn(row) {
      list.map(columns_to_test, fn(col) { Position(row, col) })
    })

  let inside_visible =
    positions_to_test
    |> list.map(is_visible(grid, _))
    |> list.filter(function.identity)
    |> list.length

  let outside_visible =
    grid.dimensions.row * 2 + { grid.dimensions.col * 2 - 4 }

  let visible_count = inside_visible + outside_visible

  io.debug(#("there are", visible_count, "visible trees"))

  Nil
}

pub fn part_two() {
  assert Ok(input) = util.read_file("src/days/eight.txt")
  let grid = parse_grid(input)

  let max_scenic_score =
    grid.items
    |> map.keys
    |> list.map(get_scenic_score(grid, _))
    |> list.fold(0, int.max)

  io.debug(#("max scenic score is", max_scenic_score))

  Nil
}
