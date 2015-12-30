defmodule Grid do
  
  def count_neighbouring_lights(grid_map, grid_length, x, y) do
    for gx <- (x - 1)..(x + 1), 
        gy <- (y - 1)..(y + 1), 
        gx >= 0 && gx < grid_length,
        gy >= 0 && gy < grid_length,
        {gx, gy} != {x, y}
    do
      # IO.inspect {x, y, gx, gy, Map.get(grid_map, {gx, gy})}
      if Map.get(grid_map, {gx, gy}) == "#", do: 1, else: 0
    end
    |> Enum.sum
  end

  def step(inputs) when is_bitstring(inputs), do: inputs |> String.split("\n", trim: true) |> step
  def step(inputs) when is_list(inputs) do
    grid_map = inputs |> Enum.with_index
    |> Enum.reduce(%{}, fn {input, y}, map ->
      input |> String.split("", trim: true) |> Enum.with_index
      |> Enum.reduce(map, fn {cell, x}, map ->
        map |> Map.put({x,y}, cell)
      end)
    end)
    grid_length = :math.sqrt(map_size(grid_map)) |> round
    corners = for x <- [0, grid_length - 1], y <- [0, grid_length - 1], do: {x,y}

    new_grid_map = 
    Enum.reduce(0..(grid_length - 1), grid_map, fn y, grid_map_acc ->
      Enum.reduce(0..(grid_length - 1), grid_map_acc, fn x, grid_map_acc ->
        new_state = if {x, y} in corners do
          "#"
        else
          lights_count = count_neighbouring_lights(grid_map, grid_length, x, y)
          case Map.get(grid_map, {x,y}) do
            "#" -> if lights_count in 2..3, do: "#", else: "."
            "." -> if lights_count == 3, do: "#", else: "."
          end
        end
        grid_map_acc |> Map.put({x,y}, new_state)
      end)
    end)
    
    for y <- 0..(grid_length - 1) do 
      for x <- 0..(grid_length - 1), into: "", do: Map.get(new_grid_map, {x,y})
    end
  end

  def count_grid_lights(inputs) do
    inputs
    |> Enum.join("\n")
    |> String.split("")
    |> Enum.filter(&(&1 == "#"))
    |> Enum.count
  end

end

result = 
"""
##.#.#
...##.
#....#
..#...
#.#..#
####.#
"""
|> String.split("\n", trim: true)

result = result |> Grid.step
^result = 
"""
#.##.#
####.#
...##.
......
#...#.
#.####
""" 
|> String.split("\n", trim: true)

result = result |> Grid.step
^result =
"""
#..#.#
#....#
.#.##.
...##.
.#..##
##.###
"""
|> String.split("\n", trim: true)

result = result |> Grid.step
^result =
"""
#...##
####.#
..##.#
......
##....
####.#
"""
|> String.split("\n", trim: true)

result = result |> Grid.step
^result =
"""
#.####
#....#
...#..
.##...
#.....
#.#..#
"""
|> String.split("\n", trim: true)

result = result |> Grid.step
^result =
"""
##.###
.##..#
.##...
.##...
#.#...
##...#
"""
|> String.split("\n", trim: true)

result = result |> Grid.count_grid_lights 
^result = 17

result = Path.join(__DIR__, "input.txt")
|> File.read!
|> (fn input ->
  1..100 |> Enum.reduce(input, fn _, acc -> Grid.step(acc) end)
end).()
|> Grid.count_grid_lights
|> IO.inspect

^result = 1006

