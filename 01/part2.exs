result = Path.join(__DIR__, "input.txt")
|> File.read!
|> String.split("", trim: true)
|> Enum.reduce({0, 0, false}, fn instr, {floor, pos, found_pos} ->
  floor = case instr do
    "(" -> floor + 1
    ")" -> floor - 1
    _ -> raise "Unknown instr: #{inspect instr}"
  end
  pos = pos + 1
  found_pos = if !found_pos && floor == -1, do: pos, else: found_pos
  {floor, pos, found_pos}
end)
|> elem(2)
|> IO.inspect

^result = 1771
