import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/map.{Map}
import gleam/option.{Some}
import gleam/regex.{Match}
import gleam/result
import gleam/set.{Set}
import gleam/string
import grid.{Grid, Position}
import util

pub type Cell {
  SensorPoint
  Beacon
  NoBeacon
  PotentialBeacon
  FoundBeacon
}

pub type ClosestBeacons =
  Map(Position, Position)

pub fn parse_input(input: String) -> ClosestBeacons {
  assert Ok(re) =
    regex.from_string(
      "Sensor at x=(-?\\d+), y=(-?\\d+): closest beacon is at x=(-?\\d+), y=(-?\\d+)",
    )

  input
  |> string.trim
  |> string.split(on: "\n")
  |> list.map(fn(line) {
    assert [
      Match(
        submatches: [
          Some(sensor_x),
          Some(sensor_y),
          Some(beacon_x),
          Some(beacon_y),
        ],
        ..,
      ),
    ] = regex.scan(re, string.trim(line))

    assert Ok(sensor_x) = int.parse(sensor_x)
    assert Ok(sensor_y) = int.parse(sensor_y)
    assert Ok(beacon_x) = int.parse(beacon_x)
    assert Ok(beacon_y) = int.parse(beacon_y)

    #(Position(sensor_x, sensor_y), Position(beacon_x, beacon_y))
  })
  |> map.from_list
}

pub fn manhattan_distance(from: Position, to: Position) -> Int {
  int.absolute_value(from.x - to.x) + int.absolute_value(from.y - to.y)
}

pub type Perimeter {
  Perimeter(points: List(Position), distance: Int)
}

fn cant_be_beacon(cavern: ClosestBeacons, position: Position) -> Bool {
  cavern
  |> map.to_list
  |> list.any(fn(pair) {
    let #(sensor, beacon) = pair
    let distance = manhattan_distance(sensor, beacon)
    let sample_distance = manhattan_distance(sensor, position)
    sample_distance <= distance
  })
}

pub fn is_contained(perimeter: Perimeter, position: Position) -> Bool {
  let up_check =
    iterator.range(-1, -2 * perimeter.distance)
    |> iterator.map(fn(row) { grid.shift(position, Position(0, row)) })
    |> iterator.find(fn(pos) { list.contains(perimeter.points, pos) })

  let right_check =
    iterator.range(1, 2 * perimeter.distance)
    |> iterator.map(fn(col) { grid.shift(position, Position(col, 0)) })
    |> iterator.find(fn(pos) { list.contains(perimeter.points, pos) })

  let down_check =
    iterator.range(1, 2 * perimeter.distance)
    |> iterator.map(fn(row) { grid.shift(position, Position(0, row)) })
    |> iterator.find(fn(pos) { list.contains(perimeter.points, pos) })

  let left_check =
    iterator.range(-1, -2 * perimeter.distance)
    |> iterator.map(fn(col) { grid.shift(position, Position(col, 0)) })
    |> iterator.find(fn(pos) { list.contains(perimeter.points, pos) })

  list.contains(perimeter.points, position) || list.all(
    [up_check, right_check, down_check, left_check],
    result.is_ok,
  )
}

pub fn part_one() {
  let input =
    "Sensor at x=2, y=18: closest beacon is at x=-2, y=15
Sensor at x=9, y=16: closest beacon is at x=10, y=16
Sensor at x=13, y=2: closest beacon is at x=15, y=3
Sensor at x=12, y=14: closest beacon is at x=10, y=16
Sensor at x=10, y=20: closest beacon is at x=10, y=16
Sensor at x=14, y=17: closest beacon is at x=10, y=16
Sensor at x=8, y=7: closest beacon is at x=2, y=10
Sensor at x=2, y=0: closest beacon is at x=2, y=10
Sensor at x=0, y=11: closest beacon is at x=2, y=10
Sensor at x=20, y=14: closest beacon is at x=25, y=17
Sensor at x=17, y=20: closest beacon is at x=21, y=22
Sensor at x=16, y=7: closest beacon is at x=15, y=3
Sensor at x=14, y=3: closest beacon is at x=15, y=3
Sensor at x=20, y=1: closest beacon is at x=15, y=3"

  assert Ok(input) = util.read_file("src/days/fifteen.txt")
  let sensor_to_beacon = parse_input(input)
  let not_beacons_in_row =
    iterator.range(-10_000_000, 10_000_000)
    |> iterator.map(fn(col) { Position(col, 2_000_000) })
    |> iterator.filter(cant_be_beacon(sensor_to_beacon, _))
    |> iterator.to_list
    |> list.length

  io.debug(#("there are", not_beacons_in_row, "locations that can't be beacons"))
  Nil
}

pub type Sensor {
  Sensor(sensor: Position, beacon: Position, distance: Int)
}

pub type Range {
  Range(start: Int, end: Int)
}

pub fn part_two() {
  let input =
    "Sensor at x=2, y=18: closest beacon is at x=-2, y=15
Sensor at x=9, y=16: closest beacon is at x=10, y=16
Sensor at x=13, y=2: closest beacon is at x=15, y=3
Sensor at x=12, y=14: closest beacon is at x=10, y=16
Sensor at x=10, y=20: closest beacon is at x=10, y=16
Sensor at x=14, y=17: closest beacon is at x=10, y=16
Sensor at x=8, y=7: closest beacon is at x=2, y=10
Sensor at x=2, y=0: closest beacon is at x=2, y=10
Sensor at x=0, y=11: closest beacon is at x=2, y=10
Sensor at x=20, y=14: closest beacon is at x=25, y=17
Sensor at x=17, y=20: closest beacon is at x=21, y=22
Sensor at x=16, y=7: closest beacon is at x=15, y=3
Sensor at x=14, y=3: closest beacon is at x=15, y=3
Sensor at x=20, y=1: closest beacon is at x=15, y=3"

  assert Ok(input) = util.read_file("src/days/fifteen.txt")
  let sensors =
    parse_input(input)
    |> map.to_list
    |> list.map(fn(pair) {
      let #(sensor, beacon) = pair
      Sensor(sensor, beacon, manhattan_distance(sensor, beacon))
    })

  assert Ok(beacon_position) =
    iterator.range(0, 4_000_000)
    |> iterator.map(fn(row) {
      sensors
      |> list.filter(fn(sensor) {
        let distance = int.absolute_value(row - sensor.sensor.y)
        let offset = sensor.distance - distance
        let width = offset * 2 + 1
        width > 0
      })
      |> list.map(fn(sensor) {
        let distance = int.absolute_value(row - sensor.sensor.y)
        let offset = sensor.distance - distance
        let from = sensor.sensor.x - offset
        let to = sensor.sensor.x + offset
        Range(start: int.max(0, from), end: int.min(4_000_000, to))
      })
      |> list.sort(fn(a, b) { int.compare(a.start, b.start) })
      |> list.fold(
        [],
        fn(ranges, range) {
          let new_start = range.start
          let new_end = range.end
          case ranges {
            [] -> [range]
            [Range(_start, end)] if new_start > end ->
              list.append(ranges, [range])
            [Range(start, end)] -> [
              Range(
                start: int.min(start, new_start),
                end: int.max(end, new_end),
              ),
            ]
            _ -> ranges
          }
        },
      )
      |> fn(ranges) { #(row, ranges) }
    })
    |> iterator.find(fn(pair) {
      let #(_row, ranges) = pair
      list.length(ranges) == 2
    })

  assert #(row, [Range(_start, hole_start), _]) = beacon_position

  io.debug(#(
    "the tuning frequency of the beacon is",
    { hole_start + 1 } * 4_000_000 + row,
  ))

  Nil
}

pub fn print_cavern(cavern: Grid(Cell)) {
  io.println(grid.to_string(
    cavern,
    fn(cell) {
      case cell {
        Ok(SensorPoint) -> "S"
        Ok(Beacon) -> "B"
        Ok(NoBeacon) -> "#"
        Ok(PotentialBeacon) -> "P"
        Ok(FoundBeacon) -> "F"
        Error(_nil) -> "."
      }
    },
  ))
}
