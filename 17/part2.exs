defmodule Container do
  require Bitwise

  def parse_inputs(inputs) do
    inputs 
    |> String.split("\n", trim: true)
    |> Enum.with_index
    |> Enum.map(fn {str, index} -> {String.to_integer(str), :math.pow(2, index) |> round} end)
  end

  def calc_qty(container_specs, combi_int) do
    container_specs
    |> Enum.reduce({0, []}, fn {qty, int}, {qty_acc, container_acc} ->
      if Bitwise.band(combi_int, int) > 0 do 
        {qty_acc + qty, [qty | container_acc]}
      else
        {qty_acc, container_acc}
      end
    end)
  end

  def find_combinations(container_specs, required_qty) do
    combi_int_limit = round(:math.pow(2, length(container_specs))) - 1
    0..combi_int_limit
    |> Enum.reduce([], fn combi_int, acc ->
      case calc_qty(container_specs, combi_int) do
        {^required_qty, containers} -> [containers | acc]
        _ -> acc
      end
    end)
  end

end

result =
"""
20
15
10
5
5
"""
|> Container.parse_inputs
|> Container.find_combinations(25)
|> Enum.group_by(&length/1)
|> Enum.min_by(&elem(&1, 0))
|> elem(1)
|> IO.inspect
|> Enum.count
|> IO.inspect

^result = 3


result = Path.join(__DIR__, "input.txt")
|> File.read!
|> Container.parse_inputs
|> Container.find_combinations(150)
|> Enum.group_by(&length/1)
|> Enum.min_by(&elem(&1, 0))
|> elem(1)
|> Enum.count
|> IO.inspect

^result = 57
