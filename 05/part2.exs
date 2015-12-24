defmodule NiceString do

  def letter_pair_appear_twice?(str) do
    if String.length(str) < 4 do
      false
    else
      {pair, match_str} = String.split_at(str, 2)
      if String.contains?(match_str, pair) do
        true
      else
        {h, t} = String.split_at(str, 1)
        letter_pair_appear_twice?(t)
      end
    end
  end

  def letter_repeats_with_one_gap?(str) do
    if String.length(str) < 3 do
      false
    else
      if String.at(str, 0) == String.at(str, 2) do
        true
      else
        {h, t} = String.split_at(str, 1)
        letter_repeats_with_one_gap?(t)
      end
    end
  end

  def nice?(str) do
    with true <- NiceString.letter_pair_appear_twice?(str),
      true <- NiceString.letter_repeats_with_one_gap?(str)
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

^result = 69
