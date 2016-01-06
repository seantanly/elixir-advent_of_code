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
    |> Enum.filter(fn x -> house_num / x <= 50 end)
    |> Enum.sum
    |> :erlang.*(11)
  end

  def min_house(presents), do: min_house(presents, 1)
  def min_house(presents, house_num) do
    cond do
      house_presents(house_num) >= presents -> house_num
      true -> min_house(presents, house_num + 1)
    end
  end

end

# Found solution in 57 seconds.
result = M.min_house(29_000_000)
|> IO.inspect

^result = 705600
