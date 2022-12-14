import gleam/io
import gleam/list
import util
import days/one
import days/two
import days/three
import days/four
import days/five
import days/six
import days/seven
import days/eight
import days/nine
import days/ten
import days/eleven
import days/twelve
import days/fourteen
import days/fifteen
import days/seventeen

pub fn main() {
  [
    // #(one.part_one, "Day 1 Part 1: "),
    // #(one.part_two, "Day 1 Part 2: "),
    // #(two.part_one, "Day 2 Part 1: "),
    // #(two.part_two, "Day 2 Part 2: "),
    // #(three.part_one, "Day 3 Part 1: "),
    // #(three.part_two, "Day 3 Part 2: "),
    // #(four.part_one, "Day 4 Part 1: "),
    // #(four.part_two, "Day 4 Part 2: "),
    // #(five.part_one, "Day 5 Part 1: "),
    // #(five.part_two, "Day 5 Part 2: "),
    // #(six.part_one, "Day 6 Part 1: "),
    // #(six.part_two, "Day 6 Part 2: "),
    // #(seven.part_one, "Day 7 Part 1: "),
    // #(seven.part_two, "Day 7 Part 2: "),
    // #(eight.part_one, "Day 8 Part 1: "),
    // #(eight.part_two, "Day 8 Part 2: "),
    // #(nine.part_one, "Day 9 Part 1: "),
    // #(nine.part_two, "Day 9 Part 2: "),
    // #(ten.part_one, "Day 10 Part 1: "),
    // #(ten.part_two, "Day 10 Part 2: "),
    // #(eleven.part_one, "Day 11 Part 1: "),
    // #(eleven.part_two, "Day 11 Part 2: "),
    // #(twelve.part_one, "Day 12 Part 1: "),
    // #(twelve.part_two, "Day 12 Part 2: "),
    // // #(thirteen.part_one, "Day 13 Part 1: "),
    // #(fourteen.part_one, "Day 14 Part 1: "),
    // #(fourteen.part_two, "Day 14 Part 2: "),
    // #(fifteen.part_one, "Day 15 Part 1: "),
    // #(fifteen.part_two, "Day 15 Part 2: "),
    #(seventeen.part_one, "Day 17 Part 1: "),
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
