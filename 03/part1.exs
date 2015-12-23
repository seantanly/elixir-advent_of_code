result = Path.join(__DIR__, "input.txt")
|> File.read!
|> String.split("", trim: true)
|> Enum.reduce({0, 0, Set.put(MapSet.new, {0,0})}, fn instr, {x, y, set} ->
  {x, y} = case instr do
    "^" -> {x, y - 1}
    "v" -> {x, y + 1}
    ">" -> {x + 1, y}
    "<" -> {x - 1, y}
    _ -> raise "Unknown instr: #{inspect instr}"
  end
  {x, y, Set.put(set, {x, y})}
end)
|> elem(2)
|> MapSet.size
|> IO.inspect

^result = 2592
