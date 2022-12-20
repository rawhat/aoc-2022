import gleam/dynamic
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import matrix
import util

external type Graph

external type Edge

type GraphType {
  Cyclic
}

external fn new_graph(types: List(GraphType)) -> Graph =
  "digraph" "new"

type Vertex {
  Vertex(x: Int, y: Int, value: String)
}

external fn add_vertex(graph: Graph, vertex: Vertex) -> Vertex =
  "digraph" "add_vertex"

external fn add_edge(graph: Graph, v1: Vertex, v2: Vertex) -> Edge =
  "digraph" "add_edge"

external fn vertices(graph: Graph) -> List(Vertex) =
  "digraph" "vertices"

external fn short_path(graph: Graph, v1: Vertex, v2: Vertex) -> List(Vertex) =
  "digraph" "get_short_path"

external fn next_codepoint(value: String) -> List(Int) =
  "string" "next_codepoint"

fn is_valid_move(source: String, destination: String) -> Bool {
  let source = case source {
    "S" -> "a"
    "E" -> "z"
    src -> src
  }
  let destination = case destination {
    "S" -> "a"
    "E" -> "z"
    dest -> dest
  }
  assert [src, ..] = next_codepoint(source)
  assert [dest, ..] = next_codepoint(destination)
  let diff = dest - src
  diff <= 1
}

type State {
  State(graph: Graph, start: Vertex, end: Vertex)
}

fn parse_input(input: String) -> State {
  let grid = matrix.from_character_map(input)

  let graph = new_graph([Cyclic])

  grid
  |> matrix.to_iterator
  |> iterator.to_list
  |> list.each(fn(element) {
    assert #(#(x, y), value) = element
    let adjacents =
      grid
      |> matrix.get_adjacents(#(x, y), False)
      |> list.filter(fn(element) {
        assert #(_position, dest) = element
        is_valid_move(value, dest)
      })

    let vertex = add_vertex(graph, Vertex(x, y, value))
    list.each(
      adjacents,
      fn(element) {
        assert #(#(x, y), value) = element
        let new_vertex = add_vertex(graph, Vertex(x, y, value))
        add_edge(graph, vertex, new_vertex)
      },
    )
  })

  assert Ok(#(#(x, y), value)) =
    grid
    |> matrix.to_iterator
    |> iterator.find(fn(element) {
      assert #(_position, value) = element
      value == "S"
    })
  let start = Vertex(x, y, value)

  assert Ok(#(#(x, y), value)) =
    grid
    |> matrix.to_iterator
    |> iterator.find(fn(element) {
      assert #(_position, value) = element
      value == "E"
    })
  let end = Vertex(x, y, value)

  State(graph, start, end)
}

pub fn part_one() {
  assert Ok(input) = util.read_file("src/days/twelve.txt")

  let state = parse_input(input)

  let path = short_path(state.graph, state.start, state.end)

  io.debug(#("short path is", list.length(path) - 1))

  Nil
}

pub fn part_two() {
  assert Ok(input) = util.read_file("src/days/twelve.txt")

  let state = parse_input(input)

  let lowest_points =
    state.graph
    |> vertices
    |> list.filter(fn(vertex) { vertex.value == "a" })

  let shortest_path =
    lowest_points
    |> list.map(fn(point) {
      // Should handle there not being a path more accurately, but I don't feel
      // like pushing this to FFI
      let path = short_path(state.graph, point, state.end)
      case dynamic.classify(dynamic.from(path)) {
        "List" -> list.length(path) - 1
        _ -> 10_000
      }
    })
    |> list.fold(10_000, int.min)

  io.debug(#("shortest path from low point is", shortest_path))

  Nil
}
