defmodule Plant do

  def parse_inputs(inputs) do
    input_lines = inputs
    |> String.split("\n", trim: true)
    {spec_strs, [initial]} = Enum.split(input_lines, length(input_lines) - 1)
    spec_map = spec_strs
    |> Enum.reduce(%{}, fn spec_str, spec_map ->
      [key, "=>", val] = String.split(spec_str, " ", trim: true)
      prev_vals = Map.get(spec_map, key, [])
      spec_map |> Map.put(key, [val | prev_vals])
    end)
    {spec_map, initial}
  end

  def get_str_replace_combinations(initial, pattern, replacement) do
    matches = :binary.matches(initial, pattern)
    for match <- matches do
      :binary.replace(initial, pattern, replacement, [{:scope, match}])
    end
  end

  def step({spec_map, initial}) do
    spec_map |> Enum.reduce([], fn {val, replacements}, set_acc ->
      replacements |> Enum.reduce(set_acc, fn replacement, set_acc ->
        combis = initial
        |> get_str_replace_combinations(val, replacement)
        combis |> Enum.reduce(set_acc, fn combi, set_acc -> [combi | set_acc] end)
      end)
    end)
  end

end

result =
"""
H => HO
H => OH
O => HH

HOH
"""
|> Plant.parse_inputs
|> Plant.step
|> IO.inspect
|> (&({&1, Enum.count(&1) |> IO.inspect} |> elem(0))).()
|> Enum.uniq
|> Enum.count
|> IO.inspect

^result = 4

result =
"""
H => HO
H => OH
O => HH

HOHOHO
"""
|> Plant.parse_inputs
|> Plant.step
|> (&({&1, Enum.count(&1) |> IO.inspect} |> elem(0))).()
|> Enum.uniq
|> Enum.count
|> IO.inspect

^result = 7

result =
"""
H => OO

H2O
"""
|> Plant.parse_inputs
|> Plant.step
|> Enum.uniq
|> IO.inspect
|> Enum.count

^result = 1

result = Path.join(__DIR__, "input.txt")
|> File.read!
|> Plant.parse_inputs
|> Plant.step
|> Enum.uniq
|> Enum.count
|> IO.inspect

^result = 576
