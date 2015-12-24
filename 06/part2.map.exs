# Takes 45 secs to complete. Map isn't terribly performant because it's immutable yet this problem requires numerous updates to the data structure.
# Each update triggers a recreation of entire data structure.
defmodule LightArray do

  def str_to_pos(str), do: str |> String.split(",", trim: true) |> Enum.map(&String.to_integer/1) |> List.to_tuple

  def exec_cmd(cmd_str, grid) do
    [_, cmd, start_pos, end_pos] = Regex.run(~r/([\w ]+) (\d+,\d+) through (\d+,\d+)/, cmd_str)
    {x1, y1} = str_to_pos(start_pos)
    {x2, y2} = str_to_pos(end_pos)

    Enum.reduce(x1..x2, grid, fn x, acc ->
      Enum.reduce(y1..y2, acc, fn y, acc2 ->
        pos = {x, y}
        case cmd do
          "turn on" -> Map.update(acc2, pos, 1, &(&1 + 1))
          "toggle" -> Map.update(acc2, pos, 2, &(&1 + 2))
          "turn off" -> Map.update(acc2, pos, 0, &(Enum.max([0, &1 - 1])))
          _ -> raise "Unknown cmd: #{inspect cmd_str}"
        end
      end)
    end)
  end

end

result = Path.join(__DIR__, "input.txt")
|> File.read!
|> String.split("\n", trim: true)
|> Enum.reduce(%{}, fn cmd_str, grid -> LightArray.exec_cmd(cmd_str, grid) end)
|> Enum.reduce(0, fn {_k, v}, acc -> acc + v end)
|> IO.inspect

^result = 15343601
