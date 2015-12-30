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

  def calc_score_calories(specs, ingrd_qtys) do
    ingrd_qtys
    |> Enum.reduce(%{}, fn {name, qty}, acc ->
      specs[name]
      |> Enum.reduce(acc, fn {k, v}, acc ->
        acc |> Map.put(k, Map.get(acc, k, 0) + (v * qty))
      end)
    end) # sum each properties into map
    |> Enum.reduce({1, 0}, fn {k, v}, {score, calories} ->
      case k do
        :calories -> {score, calories + v}
        _ -> {Enum.max([0, v]) * score, calories}
      end
    end)
  end

  def top_score(specs, total_qty, total_calories) do
    find_top_score(specs, total_calories, total_qty, Map.keys(specs), [])
  end

  def find_top_score(specs, _total_calories, 0, [], acc) do
    {score, calories} = calc_score_calories(specs, acc)
    {acc, score, calories}
  end
  def find_top_score(specs, total_calories, qty, [ingrd | ingrds], acc) do
    if ingrds == [] do
      ingrd_qty = qty
      qty_left = qty - ingrd_qty
      find_top_score(specs, total_calories, qty_left, ingrds, [{ingrd, ingrd_qty} | acc])
    else
      combinations = for ingrd_qty <- 0..qty do
        qty_left = qty - ingrd_qty
        find_top_score(specs, total_calories, qty_left, ingrds, [{ingrd, ingrd_qty} | acc])
      end
      |> Enum.filter(fn 
        :none -> false
        {_combi, _score, calories} -> calories == total_calories 
      end)
      if combinations == [] do
        :none
      else
        combinations |> Enum.max_by(&elem(&1, 1))
      end
    end
  end
end

result =
"""
Butterscotch: capacity -1, durability -2, flavor 6, texture 3, calories 8
Cinnamon: capacity 2, durability 3, flavor -2, texture -1, calories 3
"""
|> Cookie.parse_ingredients
|> Cookie.top_score(100, 500)
|> IO.inspect
|> elem(1)
|> IO.inspect

^result = 57600000

result = Path.join(__DIR__, "input.txt")
|> File.read!
|> Cookie.parse_ingredients
|> Cookie.top_score(100, 500)
|> IO.inspect
|> elem(1)
|> IO.inspect

^result = 11171160

