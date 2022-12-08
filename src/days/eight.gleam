import gleam/int
import gleam/list
import gleam/map.{Map}
import gleam/string
import util

pub type Position {
  Position(row: Int, col: Int)
}

pub type GridItems = Map(Position, Int)

pub type Grid {
  Grid(items: GridItems, dimensions: Position)
}

fn parse_grid(input: String) -> Grid {
  let rows = string.split(input, on: "\n")
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
