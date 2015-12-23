result = Path.join(__DIR__, "input.txt")
|> File.read!
|> String.split("", trim: true)
|> Enum.reduce(0, fn instr, acc ->
  case instr do
    "(" -> acc + 1
    ")" -> acc - 1
    _ -> raise "Unknown instr: #{inspect instr}"
  end
end)
|> IO.inspect

^result = 138
