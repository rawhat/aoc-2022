import gleam/int
import gleam/io
import gleam/list
import gleam/map.{Map}
import gleam/option
import gleam/string
import util

pub type File {
  File(name: String, size: Int)
}

pub type Change {
  Up
  Dir(path: String)
}

pub type Entry {
  DirEntry(name: String)
  FileEntry(name: String, size: Int)
}

pub type Command {
  Cd(Change)
  Ls(contents: List(Entry))
}

pub type FileSystem =
  Map(String, List(File))

fn parse_cd(command: String) -> Command {
  assert [_, _cd, path] = string.split(command, on: " ")
  case path {
    ".." -> Cd(Up)
    path -> Cd(Dir(path))
  }
}

fn parse_ls(lines: List(String)) -> Command {
  assert [_ls, ..outputs] = lines

  let contents =
    list.map(
      outputs,
      fn(output) {
        case string.split(output, on: " ") {
          ["dir", dirname] -> DirEntry(dirname)
          [size, filename] -> {
            assert Ok(size) = int.parse(size)
            FileEntry(filename, size)
          }
        }
      },
    )

  Ls(contents)
}

fn get_commands(lines: List(String)) -> List(Command) {
  let grouped_commands =
    list.fold(
      lines,
      [],
      fn(groups, entry) {
        case string.starts_with(entry, "$ ") {
          True -> [[entry], ..groups]
          False -> {
            assert [current, ..rest] = groups
            [[entry, ..current], ..rest]
          }
        }
      },
    )

  list.fold(
    grouped_commands,
    [],
    fn(commands, group) {
      let command = case group {
        [cd] -> parse_cd(cd)
        ls ->
          ls
          |> list.reverse
          |> parse_ls
      }

      [command, ..commands]
    },
  )
}

fn build_filesystem(
  fs: FileSystem,
  commands: List(Command),
  current_path: List(String),
) -> FileSystem {
  case commands, current_path {
    [], _path -> fs
    [Cd(Up), ..rest], [_current, ..path] -> build_filesystem(fs, rest, path)
    [Cd(Dir("/")), ..rest], _path -> build_filesystem(fs, rest, [""])
    [Cd(Dir(path)), ..rest], _path ->
      build_filesystem(fs, rest, [path, ..current_path])
    [Ls(entries), ..rest], _path -> {
      let joined_path =
        current_path
        |> list.reverse
        |> string.join("/")
      entries
      |> list.fold(
        fs,
        fn(filesystem, entry) {
          case entry {
            DirEntry(name) ->
              map.update(
                filesystem,
                joined_path <> "/" <> name,
                option.unwrap(_, []),
              )
            FileEntry(name, size) ->
              map.update(
                filesystem,
                joined_path,
                fn(existing) {
                  existing
                  |> option.unwrap([])
                  |> list.prepend(File(name, size))
                },
              )
          }
        },
      )
      |> build_filesystem(rest, current_path)
    }
  }
}

fn files_size(files: List(File)) -> Int {
  list.fold(files, 0, fn(sum, file) { sum + file.size })
}

fn get_directory_sizes(fs: FileSystem) -> Map(String, Int) {
  fs
  |> map.to_list
  |> list.map(fn(pair) {
    assert #(dir, files) = pair
    let dir_size = files_size(files)

    let subdirectories =
      fs
      |> map.keys
      |> list.filter(fn(key) { string.starts_with(key, dir) && key != dir })

    let subdirectory_sizes =
      list.fold(
        subdirectories,
        0,
        fn(sum, dir) {
          assert Ok(files) = map.get(fs, dir)
          sum + files_size(files)
        },
      )

    #(dir, dir_size + subdirectory_sizes)
  })
  |> map.from_list
}

pub fn part_one() {
  assert Ok(lines) = util.read_lines("src/days/seven.txt")

  lines
  |> get_commands()
  |> build_filesystem(map.new(), _, [])
  |> get_directory_sizes
  |> map.values
  |> list.filter(fn(size) { size <= 100000 })
  |> int.sum
  |> fn(sum) { io.debug(#("total sum of directories is", sum)) }

  Nil
}

pub fn part_two() {
  assert Ok(lines) = util.read_lines("src/days/seven.txt")

  let filesystem =
    lines
    |> get_commands()
    |> build_filesystem(map.new(), _, [])

  let directory_sizes = get_directory_sizes(filesystem)

  let root_size =
    filesystem
    |> map.values
    |> list.flatten
    |> list.map(fn(file) { file.size })
    |> int.sum

  let free_space_needed = 30000000 - { 70000000 - root_size }

  assert Ok(size_to_delete) =
    directory_sizes
    |> map.values
    |> list.sort(int.compare)
    |> list.drop_while(fn(size) { size < free_space_needed })
    |> list.at(0)

  io.debug(#("the size of the directory to delete is", size_to_delete))

  Nil
}
