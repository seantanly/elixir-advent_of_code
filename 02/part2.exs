result = Path.join(__DIR__, "input.txt")
|> File.read!
|> String.split("\n", trim: true)
|> Enum.reduce(0, fn dimensions, acc ->
  [l, w, h] = dimensions |> String.split("x") |> Enum.map(&String.to_integer/1)
  sides = [l+w, w+h, h+l]
  acc + Enum.min(sides) * 2 + (l * w * h)
end)
|> IO.inspect

^result = 3737498
