import gleeunit/should
import days/thirteen.{Packet, is_correct_order, make_stack}

fn get_packet(left: String, right: String) -> Packet {
  Packet(make_stack(left), make_stack(right))
}

pub fn it_should_validate_peoples_inputs_one_test() {
  let left =
    "[[[4, [9, 1, 0, 6], [4, 1, 3]], [0], [[4, 1], 10, [1, 5, 2, 1], 1, 5], [2, 5, [10, 4, 4, 10, 4], 0], 7], [3, [[0, 5, 9, 6, 5], [7], 8]], [], [4, 4], []]"
  let right =
    "[[[[7, 8, 5]], 0, 5, [0, [7, 8, 8, 5], [], 7, 10]], [[3, 8, [10, 6], 2], 8, [1, [9, 8, 4, 5, 9], 8, [4, 3, 8, 2], [2, 5, 7]], 10], [[10, 9, 1, 6, 0], [1, [6, 10, 8], [7, 3, 0, 0, 6]]], [9, 8, [[3, 5], [0, 7, 7, 2], 7]], [[], 1, [1], [1, 10], 3]]"

  get_packet(left, right)
  |> is_correct_order
  |> should.equal(True)
}

pub fn it_should_validate_peoples_inputs_two_test() {
  let left =
    "[[[4, [9, 1, 0, 6], [4, 1, 3]], [0], [[4, 1], 10, [1, 5, 2, 1], 1, 5], [2, 5, [10, 4, 4, 10, 4], 0], 7], [3, [[0, 5, 9, 6, 5], [7], 8]], [], [4, 4], []]"
  let right =
    "[[[[7, 8, 5]], 0, 5, [0, [7, 8, 8, 5], [], 7, 10]], [[3, 8, [10, 6], 2], 8, [1, [9, 8, 4, 5, 9], 8, [4, 3, 8, 2], [2, 5, 7]], 10], [[10, 9, 1, 6, 0], [1, [6, 10, 8], [7, 3, 0, 0, 6]]], [9, 8, [[3, 5], [0, 7, 7, 2], 7]], [[], 1, [1], [1, 10], 3]]"

  get_packet(left, right)
  |> is_correct_order
  |> should.equal(True)
}

pub fn it_should_validate_peoples_inputs_three_test() {
  let left =
    "[[4, [[8, 3, 2, 9], 7, 8], [3, [5, 10], [8, 4, 4, 5], [1, 10, 6, 1, 9]], [9, 4, [], 10], []], [[3, 8, [0, 0, 4], 1, 6], 3, [1, 5, 6]], [[4, [9], [6, 5, 10, 2]], 7], [], [0, 2, [], 8, 3]]"
  let right =
    "[[10, [[8], []], [6, [2, 7, 2, 7], [], 5]], [[[0, 0, 0]], [1, [7], 0, 2], 5, 3, [[7, 6, 8, 4]]]]"

  get_packet(left, right)
  |> is_correct_order
  |> should.equal(True)
}

pub fn it_should_validate_peoples_inputs_four_test() {
  let left = "[[], [2, 0], [6]]"
  let right = "[[[5, [6, 8, 2, 5], 7, 9, 10]], []]"

  get_packet(left, right)
  |> is_correct_order
  |> should.equal(True)
}

pub fn it_should_validate_peoples_inputs_five_test() {
  let left =
    "[[[[7], [2, 5], [4, 1, 10, 9]], [[], [6, 0, 2, 1], [0], [7, 0], 9], 8, [6], 9], [4, [], []], [2]]"
  let right = "[[7], [[6, 6]]]"

  get_packet(left, right)
  |> is_correct_order
  |> should.equal(False)
}
