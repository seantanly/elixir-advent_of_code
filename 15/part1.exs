defmodule Cookie do

  def parse_ingredients(inputs) do
    inputs
    |> String.split("\n", trim: true)
    |> Enum.reduce(%{}, fn input, spec_map ->
      [name, rest] = String.split(input, ": ")
      spec = rest
      |> String.split(", ")
      |> Enum.map(&String.split(&1, " ")) # attribute pairs
      |> Enum.reduce(%{}, fn [k, v], acc ->
        acc |> Map.put(String.to_atom(k), String.to_integer(v))
      end)
      spec_map |> Map.put(name, spec)
    end)
  end

  def calc_score(specs, ingrd_qtys) do
    ingrd_qtys
    |> Enum.reduce(%{}, fn {name, qty}, acc ->
      specs[name]
      |> Enum.reduce(acc, fn {k, v}, acc ->
        acc |> Map.put(k, Map.get(acc, k, 0) + (v * qty))
      end)
    end) # sum each properties into map
    |> Enum.reduce(1, fn {k, v}, acc ->
      case k do
        :calories -> acc
        _ -> Enum.max([0, v]) * acc
      end
    end)
  end

  def top_score(specs, total_qty) do
    find_top_score(specs, total_qty, Map.keys(specs), [])
  end

  def find_top_score(specs, 0, [], acc) do
    score = calc_score(specs, acc)
    {acc, score}
  end
  def find_top_score(specs, qty, [ingrd | ingrds], acc) do
    if ingrds == [] do
      ingrd_qty = qty
      qty_left = qty - ingrd_qty
      find_top_score(specs, qty_left, ingrds, [{ingrd, ingrd_qty} | acc])
    else
      for ingrd_qty <- 0..qty do
        qty_left = qty - ingrd_qty
        find_top_score(specs, qty_left, ingrds, [{ingrd, ingrd_qty} | acc])
      end
      |> Enum.max_by(&elem(&1, 1))
    end
  end
end

result =
"""
Butterscotch: capacity -1, durability -2, flavor 6, texture 3, calories 8
Cinnamon: capacity 2, durability 3, flavor -2, texture -1, calories 3
"""
|> Cookie.parse_ingredients
|> Cookie.top_score(100)
|> IO.inspect
|> elem(1)
|> IO.inspect

^result = 62842880

result = Path.join(__DIR__, "input.txt")
|> File.read!
|> Cookie.parse_ingredients
|> Cookie.top_score(100)
|> IO.inspect
|> elem(1)
|> IO.inspect

^result = 13882464
