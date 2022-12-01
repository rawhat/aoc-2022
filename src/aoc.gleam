import gleam/io
import gleam/list
import util
import days/one

pub fn main() {
  [
    #(one.part_one, "Day 1 Part 1: "),
    #(one.part_two, "Day 1 Part 2: "),
  ]
  |> list.each(fn(day) {
    case day {
      #(func, message) -> {
        io.print(message)
        let runtime = util.runtime_in_microseconds(func)
        io.print("  Execution time (in microseconds): ")
        io.debug(runtime)
      }
    }
  })
}
