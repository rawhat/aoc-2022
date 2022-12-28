import gleam/iterator.{Iterator}
import gleam/map.{Map}
import gleam/pair
import gleam/result
import gleam/string_builder

pub type Position {
  Position(x: Int, y: Int)
}

pub opaque type Grid(value) {
  Grid(items: Map(Position, value), rows: Int, columns: Int)
}

pub fn new() -> Grid(value) {
  Grid(items: map.new(), rows: 0, columns: 0)
}

pub fn set(grid: Grid(value), at key: Position, to value: value) -> Grid(value) {
  let new_rows = case key.y > grid.rows {
    True -> key.y
    False -> grid.rows
  }
  let new_columns = case key.x > grid.columns {
    True -> key.x
    False -> grid.columns
  }
  Grid(
    items: map.insert(grid.items, key, value),
    rows: new_rows,
    columns: new_columns,
  )
}

pub fn get(grid: Grid(value), at key: Position) -> Result(value, Nil) {
  map.get(grid.items, key)
}

pub fn row_count(grid: Grid(value)) -> Int {
  grid.rows
}

pub fn column_count(grid: Grid(value)) -> Int {
  grid.columns
}

pub fn to_iterator(
  grid: Grid(value),
) -> Iterator(#(Position, Result(value, Nil))) {
  iterator.range(0, grid.rows)
  |> iterator.flat_map(fn(row) {
    iterator.range(0, grid.columns)
    |> iterator.map(fn(col) {
      let position = Position(col, row)
      #(position, map.get(grid.items, position))
    })
  })
}

pub fn from_iterator(items: Iterator(#(Position, value))) -> Grid(value) {
  iterator.fold(
    items,
    new(),
    fn(grid, item) {
      assert #(position, value) = item
      set(grid, position, value)
    },
  )
}

// pub fn fill_holes(grid: Grid(value), with: value) -> Grid(value) {
//   grid
//   |> to_iterator
//   |> iterator.map(fn(item) { pair.map_second(item, result.unwrap(_, with)) })
//   |> from_iterator
// }

pub fn get_row(
  grid: Grid(value),
  row: Int,
) -> List(#(Position, Result(value, Nil))) {
  iterator.range(0, grid.columns)
  |> iterator.map(fn(col) {
    let position = Position(col, row)
    #(position, map.get(grid.items, position))
  })
  |> iterator.to_list
}

pub fn get_column(
  grid: Grid(value),
  column: Int,
) -> List(#(Position, Result(value, Nil))) {
  iterator.range(0, grid.rows)
  |> iterator.map(fn(row) {
    let position = Position(column, row)
    #(position, map.get(grid.items, position))
  })
  |> iterator.to_list
}

pub fn to_string(
  grid: Grid(value),
  mapper: fn(Result(value, Nil)) -> String,
) -> String {
  grid
  |> to_iterator
  |> iterator.fold(
    string_builder.new(),
    fn(builder, entry) {
      let #(position, value) = entry
      let start = case position.x == 0 {
        True -> "\n"
        False -> ""
      }
      let end = case position.x == grid.columns {
        True -> ""
        False -> " "
      }

      let entry_string = start <> mapper(value) <> end

      string_builder.append(builder, entry_string)
    },
  )
  |> string_builder.to_string
}

pub fn update(
  grid: Grid(value),
  at: Position,
  updater: fn(Result(value, Nil)) -> value,
) -> Grid(value) {
  grid
  |> get(at)
  |> updater
  |> set(grid, at, _)
}

// TODO:  support removing diagonals
pub fn get_adjacents(
  grid: Grid(value),
  of: Position,
) -> List(#(Position, Result(value, Nil))) {
  iterator.range(-1, 1)
  |> iterator.flat_map(fn(row_offset) {
    iterator.range(-1, 1)
    |> iterator.map(fn(col_offset) {
      Position(of.x + col_offset, of.y + row_offset)
    })
  })
  |> iterator.filter(fn(pos) { pos != of })
  |> iterator.map(fn(pos) { #(pos, map.get(grid.items, pos)) })
  |> iterator.to_list
}
