import gleam/int
import gleam/io
import gleam/list
import gleam/order.{Eq, Gt, Lt, Order}
import gleam/string
import util.{read_lines}

pub type Play {
  Rock
  Paper
  Scissors
}

fn compare(left: Play, right: Play) -> Order {
  case left, right {
    _, _ if left == right -> Eq
    Rock, Scissors -> Gt
    Paper, Rock -> Gt
    Scissors, Paper -> Gt
    _, _ -> Lt
  }
}

fn parse_play(str: String) -> Play {
  case str {
    "A" | "X" -> Rock
    "B" | "Y" -> Paper
    "C" | "Z" -> Scissors
  }
}

fn play_value(play: Play) -> Int {
  case play {
    Rock -> 1
    Paper -> 2
    Scissors -> 3
  }
}

pub type RPS {
  RPS(opponent: Play, player: Play)
}

fn score_play(rps: RPS) -> Int {
  let RPS(opponent, player) = rps
  let game_score = case compare(player, opponent) {
    Eq -> 3
    Gt -> 6
    Lt -> 0
  }
  game_score + play_value(player)
}

fn get_rounds(to_play: fn(List(String)) -> RPS) -> List(RPS) {
  assert Ok(lines) = read_lines("src/days/two.txt")

  lines
  |> list.map(string.split(_, " "))
  |> list.map(to_play)
}

pub fn part_one() {
  let score =
    fn(values) {
      assert [opponent, player] = values
      RPS(parse_play(opponent), parse_play(player))
    }
    |> get_rounds
    |> list.map(score_play)
    |> int.sum

  io.debug(#("score for first part", score))

  Nil
}

pub fn part_two() {
  let score =
    fn(values) {
      assert [opponent, outcome] = values
      let opponent = parse_play(opponent)
      let ordering = case outcome {
        "X" -> Lt
        "Y" -> Eq
        "Z" -> Gt
      }
      assert Ok(player) =
        list.find(
          [Rock, Paper, Scissors],
          fn(value) { compare(value, opponent) == ordering },
        )
      RPS(opponent, player)
    }
    |> get_rounds
    |> list.map(score_play)
    |> int.sum

  io.debug(#("score for second part", score))

  Nil
}
