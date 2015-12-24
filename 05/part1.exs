defmodule NiceString do

  def at_least_3_vowels?(str) do
    str |> String.split("", trim: true) |> Enum.reduce(0, fn letter, acc ->
      if letter in ~w(a e i o u), do: acc + 1, else: acc
    end) >= 3
  end

  def letter_appear_twice?(str), do: letter_appear_twice?(String.split(str, "", trim: true), nil)
  def letter_appear_twice?([], _), do: false
  def letter_appear_twice?([h | t], prev) do
    if h == prev, do: true, else: letter_appear_twice?(t, h)
  end

  def contains_bad_strings?(str) do
    ~w(ab cd pq xy) |> Enum.any?(&String.contains?(str, &1))
  end

  def nice?(str) do
    with true <- NiceString.at_least_3_vowels?(str),
      true <- NiceString.letter_appear_twice?(str),
      false <- NiceString.contains_bad_strings?(str)
    do
      :ok
    end
    |> case do
      :ok -> true
      _ -> false
    end
  end

end

result = Path.join(__DIR__, "input.txt")
|> File.read!
|> String.split("\n", trim: true)
|> Enum.reduce(0, fn(str, acc) -> if NiceString.nice?(str), do: acc + 1, else: acc end)
|> IO.inspect

^result = 238
