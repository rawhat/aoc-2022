import gleam/int
import gleam/io
import gleam/iterator.{Iterator}
import gleam/map.{Map}
import gleam/set.{Set}
import gleam/string_builder

pub type Position {
  Position(x: Int, y: Int)
}

pub opaque type Grid(value) {
  Grid(
    items: Map(Position, value),
    row_start: Int,
    row_end: Int,
    column_start: Int,
    column_end: Int,
  )
}

pub fn new() -> Grid(value) {
  Grid(
    items: map.new(),
    row_start: 0,
    row_end: 0,
    column_start: 0,
    column_end: 0,
  )
}

pub fn set(grid: Grid(value), at key: Position, to value: value) -> Grid(value) {
  let #(row_start, row_end) = case
    key.y < grid.row_start,
    key.y > grid.row_end
  {
    True, _ -> #(key.y, grid.row_end)
    _, True -> #(grid.row_start, key.y)
    _, _ -> #(grid.row_start, grid.row_end)
  }
  let #(column_start, column_end) = case
    key.x < grid.column_start,
    key.x > grid.column_end
  {
    True, _ -> #(key.x, grid.column_end)
    _, True -> #(grid.column_start, key.x)
    _, _ -> #(grid.column_start, grid.column_end)
  }
  Grid(
    items: map.insert(grid.items, key, value),
    row_start: row_start,
    row_end: row_end,
    column_start: column_start,
    column_end: column_end,
  )
}

pub fn get(grid: Grid(value), at key: Position) -> Result(value, Nil) {
  map.get(grid.items, key)
}

pub fn row_count(grid: Grid(value)) -> Int {
  int.absolute_value(grid.row_end - grid.row_start)
}

pub fn column_count(grid: Grid(value)) -> Int {
  int.absolute_value(grid.column_end - grid.column_start)
}

pub fn to_iterator(
  grid: Grid(value),
) -> Iterator(#(Position, Result(value, Nil))) {
  iterator.range(grid.row_start, grid.row_end)
  |> iterator.flat_map(fn(row) {
    iterator.range(grid.column_start, grid.column_end)
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
  iterator.range(grid.column_start, grid.column_end)
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
  iterator.range(grid.row_start, grid.row_end)
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
      let start = case position.x == grid.column_start {
        True -> "\n"
        False -> ""
      }
      let end = case position.x == grid.column_end {
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

pub fn box_of_points(
  top_left: Position,
  bottom_right: Position,
) -> Iterator(Position) {
  iterator.range(top_left.y, bottom_right.y)
  |> iterator.flat_map(fn(row) {
    iterator.range(top_left.x, bottom_right.x)
    |> iterator.map(fn(col) { Position(col, row) })
  })
}

pub fn shift(from: Position, offset: Position) -> Position {
  Position(from.x + offset.x, from.y + offset.y)
}

pub fn neighborhood(of: Position, radius: Int) -> Set(Position) {
  let top_left =
    iterator.range(radius, 0)
    |> iterator.map(fn(offset) {
      shift(of, Position(offset - radius, 0 - offset))
    })
  let top_right =
    iterator.range(0, radius)
    |> iterator.map(fn(offset) {
      shift(of, Position(radius - offset, 0 - offset))
    })
  let bottom_left =
    iterator.range(radius, 0)
    |> iterator.map(fn(offset) { shift(of, Position(offset - radius, offset)) })
  let bottom_right =
    iterator.range(0, radius)
    |> iterator.map(fn(offset) { shift(of, Position(radius - offset, offset)) })

  top_left
  |> iterator.append(top_right)
  |> iterator.append(bottom_left)
  |> iterator.append(bottom_right)
  |> iterator.to_list
  |> set.from_list
}
