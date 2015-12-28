input = Path.join(__DIR__, "input.txt")
|> File.read!

result = Regex.scan(~r/-?[\d]+/, input)
|> Enum.reduce(0, fn [str], acc -> acc + String.to_integer(str) end)
|> IO.inspect

^result = 191164
