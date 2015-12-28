defmodule Part2 do
  def run do
    result = Path.join(__DIR__, "input.txt")
    |> File.read!
    |> Poison.decode!
    |> eval
    |> IO.inspect

    ^result = 87842
  end

  def eval(val) when is_map(val) do
    if Enum.any?(val, fn {_k, v} -> v == "red" end) do
      0
    else
      Enum.reduce(val, 0, fn {_k, v}, acc -> eval(v) + acc end)
    end
  end
  def eval(val) when is_list(val), do: Enum.reduce(val, 0, &(eval(&1) + &2))
  def eval(val) when is_integer(val), do: val
  def eval(_), do: 0
end
