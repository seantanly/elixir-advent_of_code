defmodule M do

  def house_presents(house_num) do
    1..house_num |>
    Enum.reduce(0, fn elve_num, acc ->
      if rem(house_num, elve_num) != 0, do: acc, else: elve_num * 10 + acc
    end)
  end

  def min_house(presents), do: min_house(presents, 1)
  def min_house(presents, house_num) do
    cond do
      house_presents(house_num) >= presents -> house_num
      true -> min_house(presents, house_num + 1)
    end
  end
end

result = 1..9
|> Enum.map(&M.house_presents/1)
|> IO.inspect

^result = [10, 30, 40, 70, 60, 120, 80, 150, 130]

# Simple brute takes 9 secs
result = M.min_house(500_000)
|> IO.inspect

^result = 13860
# result = M.min_house(29000000)
# |> IO.inspect

# ^result = 0
