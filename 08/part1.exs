defmodule StringCount do
  def count(str) do
    [_, str] = Regex.run(~r/"(.*)"/, str)
    count(str, 2, 0)
  end

  def count("", act_len, mem_len), do: {act_len, mem_len}
  def count(str, act_len, mem_len) do
    case str do
      "\\x" <> str ->
        {_, str} = String.split_at(str, 2)
        count(str, act_len + 4, mem_len + 1)
      "\\\\" <> str ->
        count(str, act_len + 2, mem_len + 1)
      "\\\"" <> str ->
        count(str,act_len + 2, mem_len + 1)
      _ ->
        {_, str} = String.split_at(str, 1)
        count(str, act_len + 1, mem_len + 1)
    end
  end

  def diff_result({act_len, mem_len}), do: act_len - mem_len
end

result = Path.join(__DIR__, "input.txt")
|> File.read!
|> String.split("\n", trim: true)
|> Enum.reduce({0, 0}, fn str, {total_act_len, total_mem_len} ->
  {act_len, mem_len} = StringCount.count(str)
  {total_act_len + act_len, total_mem_len + mem_len}
end)
|> StringCount.diff_result
|> IO.inspect

^result = 1350
