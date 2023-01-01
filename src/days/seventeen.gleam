import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/result
import gleam/set.{Set}
import gleam/string
import grid.{Position}
import util

pub type Piece {
  Horizontal
  Plus
  Angle
  Vertical
  Square
}

pub type FallingPiece {
  FallingPiece(shape: Piece, points: List(Position))
}

pub type Direction {
  Left
  Right
}

fn parse_gusts(gusts: String) -> List(Direction) {
  gusts
  |> string.to_graphemes
  |> list.map(fn(char) {
    case char {
      ">" -> Right
      "<" -> Left
    }
  })
}

pub type Occupied =
  List(Position)

pub type Board {
  Board(
    falling_piece: FallingPiece,
    pieces: List(Piece),
    gusts: List(Direction),
    board: Set(Position),
  )
}

fn initial_position(board: Board) -> Board {
  let [piece, ..] = board.pieces
  let tallest_y =
    board.board
    |> set.to_list
    |> list.fold(
      0,
      fn(lowest, position) {
        case position.y < lowest {
          True -> position.y
          False -> lowest
        }
      },
    )
  let tallest_y = tallest_y - 4
  let positions = case piece {
    Horizontal ->
      list.range(2, 5)
      |> list.map(fn(x) { Position(x, tallest_y) })
    Plus -> [
      Position(2, tallest_y - 1),
      Position(3, tallest_y - 2),
      Position(3, tallest_y - 1),
      Position(3, tallest_y),
      Position(4, tallest_y - 1),
    ]
    Angle -> [
      Position(2, tallest_y),
      Position(3, tallest_y),
      Position(4, tallest_y),
      Position(4, tallest_y - 1),
      Position(4, tallest_y - 2),
    ]
    Vertical -> [
      Position(2, tallest_y),
      Position(2, tallest_y - 1),
      Position(2, tallest_y - 2),
      Position(2, tallest_y - 3),
    ]
    Square -> [
      Position(2, tallest_y),
      Position(3, tallest_y),
      Position(2, tallest_y - 1),
      Position(3, tallest_y - 1),
    ]
  }

  Board(..board, falling_piece: FallingPiece(piece, positions))
}

fn new_board(gusts: List(Direction)) {
  Board(
    falling_piece: FallingPiece(
      Horizontal,
      [Position(2, -3), Position(3, -3), Position(4, -3), Position(5, -3)],
    ),
    pieces: [Horizontal, Plus, Angle, Vertical, Square],
    gusts: gusts,
    board: set.new(),
  )
}

fn place_piece(board: Board) -> Board {
  Board(
    ..board,
    board: list.fold(
      board.falling_piece.points,
      board.board,
      fn(prev, point) { set.insert(prev, point) },
    ),
  )
}

fn is_invalid_position(board: Board) -> Bool {
  is_blocked_by_wall(board.falling_piece.points) || board.board
  |> set.to_list
  |> list.any(fn(existing) {
    list.contains(board.falling_piece.points, existing)
  })
}

fn is_blocked_by_wall(points: List(Position)) -> Bool {
  points
  |> list.any(fn(position) {
    position.x > 6 || position.x < 0 || position.y > 0
  })
}

fn gust(board: Board) -> Result(Board, Nil) {
  let [next_gust, ..rest] = board.gusts
  // io.println(
  //   "gusting " <> case next_gust {
  //     Left -> "left"
  //     Right -> "right"
  //   },
  // )
  let shift = case next_gust {
    Left -> Position(-1, 0)
    Right -> Position(1, 0)
  }
  let new_position =
    board.falling_piece.points
    |> list.map(grid.shift(_, shift))

  let new_board =
    Board(
      ..board,
      falling_piece: FallingPiece(..board.falling_piece, points: new_position),
    )

  case is_invalid_position(new_board) {
    True -> Ok(Board(..board, gusts: list.append(rest, [next_gust])))
    False -> Ok(Board(..new_board, gusts: list.append(rest, [next_gust])))
  }
}

fn drop(board: Board) -> Result(Board, Nil) {
  // io.println("dropping piece")
  let next_position =
    board.falling_piece.points
    |> list.map(fn(pos) { grid.shift(pos, Position(0, 1)) })
  let new_board =
    Board(
      ..board,
      falling_piece: FallingPiece(..board.falling_piece, points: next_position),
    )

  case is_invalid_position(new_board) {
    True -> Error(Nil)
    False -> Ok(new_board)
  }
}

fn next_piece(board: Board) -> Board {
  assert [current, next, ..rest] = board.pieces
  Board(..board, pieces: list.append([next, ..rest], [current]))
}

pub fn part_one() {
  assert Ok(gusts) = util.read_file("src/days/seventeen.txt")
  let board =
    gusts
    |> string.trim
    |> parse_gusts
    |> new_board
  // |> io.debug
  let runs =
    iterator.unfold(
      from: board,
      with: fn(board) {
        let next_board =
          [gust, drop]
          |> iterator.from_list
          |> iterator.cycle
          |> iterator.fold_until(
            board,
            fn(board, func) {
              board
              |> func
              |> result.map(fn(res) { list.Continue(res) })
              |> result.lazy_unwrap(fn() { list.Stop(place_piece(board)) })
            },
          )
          |> next_piece
          |> initial_position

        iterator.Next(next_board, next_board)
      },
    )

  assert Ok(last) =
    runs
    |> iterator.take(2022)
    |> iterator.last

  assert Ok(tallest_y) =
    last.board
    |> set.to_list
    |> list.map(fn(position) { position.y })
    |> list.sort(int.compare)
    |> list.at(0)
    |> result.map(int.absolute_value)
    |> result.map(fn(v) { v + 1 })

  io.debug(#("after 2022 runs, the tower is", tallest_y, "blocks tall"))

  Nil
}
