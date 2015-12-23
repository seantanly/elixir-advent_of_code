result = Path.join(__DIR__, "input.txt")
|> File.read!
|> String.split("", trim: true)
|> Enum.reduce({[{0, 0}, {0, 0}], 0, Set.put(MapSet.new, {0,0})}, fn instr, {positions, turn, set} ->
  {x, y} = positions |> Enum.at(turn)
  new_pos = case instr do
    "^" -> {x, y - 1}
    "v" -> {x, y + 1}
    ">" -> {x + 1, y}
    "<" -> {x - 1, y}
    _ -> raise "Unknown instr: #{inspect instr}"
  end
  positions = positions |> List.replace_at(turn, new_pos)
  {positions, rem(turn + 1, 2), Set.put(set, new_pos)}
end)
|> elem(2)
|> MapSet.size
|> IO.inspect

^result = 2360
