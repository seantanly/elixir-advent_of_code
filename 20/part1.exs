# Referenced solution provided on https://www.reddit.com/r/adventofcode/comments/3xjpp2/day_20_solutions/cy5ndio
# about using sqrt to reduce the problem space.
defmodule M do

  def divisors(n) do
    1..(n |> :math.sqrt |> trunc)
    |> Enum.reduce([], fn
      x, acc when n == x -> [x | acc]
      x, acc when n == x * x -> [x | acc]
      x, acc when rem(n, x) == 0 -> [div(n, x) | [x | acc]]
      _ , acc -> acc
    end)
  end

  def house_presents(house_num) do
    house_num
    |> divisors
    |> Enum.sum
    |> :erlang.*(10)
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

# Simple brute testing all 1..n without sqrt takes 9 secs, this takes 0.6 secs
result = M.min_house(500_000)
|> IO.inspect

^result = 13860

# Found solution in 51 seconds.
result = M.min_house(29_000_000)
|> IO.inspect

^result = 665280
