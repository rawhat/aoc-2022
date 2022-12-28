import gleam/function
import gleam/int
import gleam/io
import gleam/iterator.{Done, Next}
import gleam/list.{Continue, Stop}
import gleam/option.{None, Option, Some}
import gleam/string
import matrix.{Matrix}
import util

pub type Operation {
  Noop
  AddX(amount: Int)
}

pub type Machine {
  Machine(
    cycle: Int,
    register: Int,
    operations: List(Operation),
    pending_operation: Option(Operation),
  )
}

fn new_machine(operations: List(Operation)) -> Machine {
  Machine(0, 1, operations, None)
}

pub type CRT {
  CRT(grid: Matrix(String), position: #(Int, Int))
}

fn new_crt() -> CRT {
  let grid =
    matrix.new()
    |> matrix.set(#(39, 5), ".")
    |> matrix.fill_holes(function.constant("."))

  CRT(grid, #(0, 0))
}

fn draw_sprite(crt: CRT, register: Int) -> CRT {
  assert #(x, y) = crt.position
  let range = list.range(register - 1, register + 1)
  let new_grid = case list.contains(range, x) {
    True -> matrix.set(crt.grid, crt.position, "#")
    False -> crt.grid
  }

  let new_position = case x, y {
    39, y -> #(0, y + 1)
    x, y -> #(x + 1, y)
  }

  CRT(new_grid, new_position)
}

fn parse_operations(input: String) -> List(Operation) {
  input
  |> string.trim
  |> string.split(on: "\n")
  |> list.map(fn(line) {
    case string.split(line, on: " ") {
      ["addx", amount] -> {
        assert Ok(amount) = int.parse(amount)
        AddX(amount)
      }
      ["noop"] -> Noop
    }
  })
}

fn cycle(machine: Machine) -> Machine {
  case machine.pending_operation, machine.operations {
    Some(AddX(amount)), _ops ->
      Machine(
        ..machine,
        register: machine.register + amount,
        pending_operation: None,
        cycle: machine.cycle + 1,
      )
    _, [] -> machine
    _, [Noop, ..rest] ->
      Machine(..machine, operations: rest, cycle: machine.cycle + 1)
    _, [AddX(_amount) as op, ..rest] ->
      Machine(
        ..machine,
        pending_operation: Some(op),
        cycle: machine.cycle + 1,
        operations: rest,
      )
  }
}

pub fn part_one() {
  assert Ok(input) = util.read_file("src/days/ten.txt")

  let operations = parse_operations(input)
  let machine = new_machine(operations)

  let system =
    iterator.unfold(
      from: machine,
      with: fn(machine) {
        case machine.operations {
          [] -> Done
          _ -> {
            let next_machine = cycle(machine)
            Next(next_machine, next_machine)
          }
        }
      },
    )

  let cycles_to_check = [20, 60, 100, 140, 180, 220]
  let cycle_values =
    iterator.fold_until(
      system,
      [],
      fn(cycles, machine) {
        case
          list.length(cycles) == list.length(cycles_to_check),
          list.contains(cycles_to_check, machine.cycle + 1)
        {
          True, False -> Stop(cycles)
          False, True ->
            Continue([#(machine.cycle + 1, machine.register), ..cycles])
          False, False -> Continue(cycles)
        }
      },
    )

  let sum_of_values =
    list.fold(
      cycle_values,
      0,
      fn(sum, value) {
        assert #(cycle, register) = value
        sum + cycle * register
      },
    )

  io.debug(#("sum of values is", sum_of_values))

  Nil
}

pub fn part_two() {
  io.println("")

  assert Ok(input) = util.read_file("src/days/ten.txt")

  let operations = parse_operations(input)
  let machine = new_machine(operations)
  let crt = new_crt()

  assert Ok(#(_machine, crt)) =
    iterator.unfold(
      from: #(machine, crt),
      with: fn(state) {
        assert #(machine, crt) = state
        case machine.operations {
          [] -> Done
          _ -> {
            let next_crt = draw_sprite(crt, machine.register)
            let next_machine = cycle(machine)
            let next_state = #(next_machine, next_crt)
            Next(next_state, next_state)
          }
        }
      },
    )
    |> iterator.last

  io.print(matrix.to_string(crt.grid, fn(str) { option.unwrap(str, "?") }))

  Nil
}
