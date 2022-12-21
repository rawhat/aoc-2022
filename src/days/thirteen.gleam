import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import gleam/string
import util

const input = "[1,1,3,1,1]
[1,1,5,1,1]

[[1],[2,3,4]]
[[1],4]

[9]
[[8,7,6]]

[[4,4],4,4]
[[4,4],4,4,4]

[7,7,7,7]
[7,7,7]

[]
[3]

[[[]]]
[[]]

[1,[2,[3,[4,[5,6,7]]]],8,9]
[1,[2,[3,[4,[5,6,0]]]],8,9]"

pub type Entry {
  Value(Int)
  OpenBracket
  CloseBracket
}

type Stack =
  List(Entry)

pub fn make_stack(input: String) -> Stack {
  input
  |> string.to_graphemes
  |> list.fold(
    #([], ""),
    fn(state, char) {
      assert #(acc, pending) = state
      case char, pending {
        "[", "" -> #(list.append(acc, [OpenBracket]), "")
        "]", "" -> #(list.append(acc, [CloseBracket]), "")
        "]", number -> {
          assert Ok(value) = int.parse(number)
          #(list.append(acc, [Value(value), CloseBracket]), "")
        }
        " ", "" -> #(acc, "")
        ",", "" -> #(acc, "")
        ",", number -> {
          assert Ok(value) = int.parse(number)
          #(list.append(acc, [Value(value)]), "")
        }
        number, pending -> #(acc, pending <> number)
      }
    },
  )
  |> pair.first
}

pub type Packet {
  Packet(left: Stack, right: Stack)
}

fn parse_input(input: String) -> List(Packet) {
  input
  |> string.split(on: "\n\n")
  |> list.map(fn(pair) {
    assert [left, right, ..] = string.split(pair, on: "\n")
    Packet(make_stack(left), make_stack(right))
  })
}

fn stack_to_string(stack: Stack) -> String {
  stack
  |> list.map(fn(entry) {
    case entry {
      OpenBracket -> "["
      CloseBracket -> "]"
      Value(number) -> int.to_string(number)
    }
  })
  |> string.join(" ")
}

pub fn is_correct_order(packet: Packet) -> Bool {
  let Packet(left, right) = packet
  case left, right {
    [], [] | [], [_something, ..] -> True
    [_something, ..], [] -> False
    [Value(a), ..], [Value(b), ..] if a < b -> True
    [Value(a), ..], [Value(b), ..] if a > b -> False
    [Value(a), ..l_rest], [Value(b), ..r_rest] if a == b ->
      is_correct_order(Packet(l_rest, r_rest))
    [Value(a), ..l_rest], [OpenBracket, ..] ->
      is_correct_order(Packet(
        [OpenBracket, Value(a), CloseBracket, ..l_rest],
        right,
      ))
    [OpenBracket, ..], [Value(b), ..r_rest] ->
      is_correct_order(Packet(
        left,
        [OpenBracket, Value(b), CloseBracket, ..r_rest],
      ))
    [OpenBracket, CloseBracket, ..l_rest], [OpenBracket, CloseBracket, ..r_rest] ->
      is_correct_order(Packet(l_rest, r_rest))
    [OpenBracket, ..l_rest], [OpenBracket, ..r_rest] -> {
      let #(left_entries, [CloseBracket, ..l_rest]) =
        list.split_while(l_rest, fn(e) { e != CloseBracket })
      let #(right_entries, [CloseBracket, ..r_rest]) =
        list.split_while(r_rest, fn(e) { e != CloseBracket })
      let new_left = list.append(left_entries, l_rest)
      let new_right = list.append(right_entries, r_rest)
      is_correct_order(Packet(new_left, new_right))
    }
  }
}

pub fn part_one() {
  assert Ok(input) = util.read_file("src/days/thirteen.txt")
  let packets = parse_input(input)
  let valid_packets =
    packets
    |> list.index_map(fn(index, packet) {
      let is_correct = is_correct_order(packet)
      #(index + 1, is_correct)
    })
    |> list.filter(pair.second)
    |> list.map(pair.first)
    |> int.sum

  io.debug(#("valid packet index sum is", valid_packets))

  Nil
}
