defmodule StringCount do
  def count(str) do
    count(String.split(str, "", trim: true), "", 0)
  end

  def count([], new_str, ori_len) do
    new_str = ["\"", new_str, "\""] |> IO.chardata_to_string
    {new_str |> String.length, ori_len}
  end
  def count(str, new_str, ori_len) do
    [char | str] = str
    case char do
      "\"" -> count(str, [new_str, "\\\""], ori_len + 1)
      "\\" -> count(str, [new_str, "\\\\"], ori_len + 1)
      _ -> count(str, [new_str, char], ori_len + 1)
    end
  end

  def diff_result({new_len, ori_len}), do: new_len - ori_len
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

^result = 2085
