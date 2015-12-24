# Using ETS instead of Map reduces the time taken from 40 to 20 seconds.
defmodule LightArray do

  def str_to_pos(str), do: str |> String.split(",", trim: true) |> Enum.map(&String.to_integer/1) |> List.to_tuple

  def exec_cmd(cmd_str, grid) do
    [_, cmd, start_pos, end_pos] = Regex.run(~r/([\w ]+) (\d+,\d+) through (\d+,\d+)/, cmd_str)
    {x1, y1} = str_to_pos(start_pos)
    {x2, y2} = str_to_pos(end_pos)

    Enum.each(x1..x2, fn x ->
      Enum.each(y1..y2, fn y ->
        pos = {x, y}
        case cmd do
          "turn on" -> :ets.insert(grid, {pos, true})
          "toggle" -> 
            new_obj = case :ets.lookup(grid, pos) do
              [] -> {pos, true}
              [{^pos, val}] -> {pos, !val}
            end
            :ets.insert(grid, new_obj)
          "turn off" -> :ets.insert(grid, {pos, false})
          _ -> raise "Unknown cmd: #{inspect cmd_str}"
        end
      end)
    end)

    grid
  end

end

grid = :ets.new(:grid, [:set, :named_table])

result = Path.join(__DIR__, "input.txt")
|> File.read!
|> String.split("\n", trim: true)
|> Enum.reduce(grid, fn cmd_str, grid -> LightArray.exec_cmd(cmd_str, grid) end)
|> :ets.tab2list
|> Enum.reduce(0, fn {_k, v}, acc -> if v == true, do: acc + 1, else: acc end)
|> IO.inspect

^result = 400410
