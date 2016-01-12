defmodule M do

  def pos2n(row, col), do: pos2n(row, col, 1, row + 1, 1)
  def pos2n(1, 1, _row_add, _col_add, acc), do: acc
  def pos2n(1, col, row_add, col_add, acc), do: pos2n(1, col - 1, row_add, col_add + 1, acc + col_add)
  def pos2n(row, col, row_add, col_add, acc), do: pos2n(row - 1, col, row_add + 1, col_add, acc + row_add)

  def code_at_pos(row, col), do: pos2n(row, col) |> nth_code

  def nth_code(n), do: nth_code(n, 1, 20151125)
  def nth_code(n, n_acc, acc) when n == n_acc, do: acc
  def nth_code(n, n_acc, acc), do: nth_code(n, n_acc + 1, rem(acc * 252533, 33554393))
end

result = M.pos2n(4, 2)
^result = 12

result = M.pos2n(1, 5)
^result = 15

result = M.code_at_pos(1, 1)
^result = 20151125

result = M.code_at_pos(1, 6)
^result = 33511524

result = M.code_at_pos(6, 1)
^result = 33071741

result = M.code_at_pos(6, 6)
^result = 27995004

[row, col] =
  Path.join(__DIR__, "input.txt")
  |> File.read!
  |> (fn str -> 
    [_, row, col] = Regex.run(~r/.*row (\d+), column (\d+)\./, str)
    [row, col] |> Enum.map(&String.to_integer/1)
  end).()
  |> IO.inspect

result = M.code_at_pos(row, col)
|> IO.inspect

^result = 8997277
