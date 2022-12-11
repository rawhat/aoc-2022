import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/map.{Map}
import gleam/option.{Some}
import gleam/regex.{Match}
import gleam/result
import gleam/string
import util

type Test {
  Test(dividend: Int, valid: Int, invalid: Int)
}

type Monkey {
  Monkey(
    id: Int,
    inspected: Int,
    items: List(Int),
    operation: fn(Int) -> Int,
    test: Test,
  )
}

fn parse_monkey(input: String) {
  assert Ok(re) =
    regex.from_string(
      "Monkey (\\d+):\\s+Starting items: (.*)\\s+Operation: new = old (.) (.+)\\s+Test: divisible by (\\d+)\\s+If true: throw to monkey (\\d+)\\s+If false: throw to monkey (\\d+)",
    )

  assert [
    Match(
      submatches: [
        Some(id),
        Some(starting_items),
        Some(operation),
        Some(operand_or_old),
        Some(dividend),
        Some(valid_monkey),
        Some(invalid_monkey),
      ],
      ..,
    ),
    ..
  ] = regex.scan(re, input)

  assert Ok(id) = int.parse(id)
  let operand = int.parse(operand_or_old)
  assert Ok(dividend) = int.parse(dividend)
  assert Ok(valid_monkey) = int.parse(valid_monkey)
  assert Ok(invalid_monkey) = int.parse(invalid_monkey)

  let starting_items =
    starting_items
    |> string.split(", ")
    |> list.map(fn(item) {
      assert Ok(item) = int.parse(item)
      item
    })

  Monkey(
    id: id,
    inspected: 0,
    items: starting_items,
    operation: fn(prev) {
      let value = result.unwrap(operand, prev)
      case operation {
        "*" -> prev * value
        "/" -> prev / value
        "-" -> prev - value
        "+" -> prev + value
      }
    },
    test: Test(dividend: dividend, valid: valid_monkey, invalid: invalid_monkey),
  )
}

type State {
  State(round: Int, monkeys: Map(Int, Monkey), reduce_worry: Int, lcm: Int)
}

fn perform_round(state: State) -> State {
  use state, monkey_id <- iterator.fold(iterator.range(0, 7), state)
  assert Ok(current_monkey) = map.get(state.monkeys, monkey_id)
  use state, item <- list.fold(current_monkey.items, state)
  let worry_level = current_monkey.operation(item)
  let worry_level = case state.reduce_worry {
    1 -> worry_level % state.lcm
    n -> {
      assert Ok(div) = int.floor_divide(worry_level, n)
      div % state.lcm
    }
  }
  let pass_to = case worry_level % current_monkey.test.dividend == 0 {
    True -> current_monkey.test.valid
    False -> current_monkey.test.invalid
  }
  let new_monkeys =
    state.monkeys
    |> map.update(
      pass_to,
      fn(existing) {
        assert Some(monkey_to_pass) = existing
        Monkey(
          ..monkey_to_pass,
          items: list.append(monkey_to_pass.items, [worry_level]),
        )
      },
    )
    |> map.update(
      monkey_id,
      fn(existing) {
        assert Some(monkey_to_remove) = existing
        assert Ok(new_items) = list.rest(monkey_to_remove.items)
        Monkey(
          ..monkey_to_remove,
          items: new_items,
          inspected: monkey_to_remove.inspected + 1,
        )
      },
    )
  State(..state, monkeys: new_monkeys)
}

fn solve(rounds: Int, reduce_worry: Int) -> Int {
  assert Ok(input) = util.read_file("src/days/eleven.txt")

  let monkeys =
    input
    |> string.split(on: "\n\n")
    |> list.map(parse_monkey)

  let lcm =
    monkeys
    |> list.map(fn(monkey) { monkey.test.dividend })
    |> list.fold(1, fn(lcm, next) { lcm * next })

  let state =
    monkeys
    |> list.index_map(fn(index, monkey) { #(index, monkey) })
    |> map.from_list
    |> State(0, _, reduce_worry, lcm)

  let updated_state =
    iterator.range(0, rounds - 1)
    |> iterator.fold(
      state,
      fn(state, _round) {
        let new_state = perform_round(state)
        State(..new_state, round: new_state.round + 1)
      },
    )

  assert [top, second] =
    updated_state.monkeys
    |> map.values
    |> list.sort(fn(a, b) { int.compare(b.inspected, a.inspected) })
    |> list.take(2)

  top.inspected * second.inspected
}

pub fn part_one() {
  let value = solve(20, 3)

  io.debug(#(
    "product of two most active monkey inspections with reduced worry is",
    value,
  ))

  Nil
}

pub fn part_two() {
  let value = solve(10_000, 1)

  io.debug(#(
    "product of two most active monkey inspections with heightened worry is",
    value,
  ))

  Nil
}
