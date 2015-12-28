# Solution without parsing JSON.

defmodule Abacus do

  def clean_input(str) do
    str
    |> String.split("")
    |> clean_input([{[], :base}])
    |> Enum.join
  end
  def clean_input([], [{buff, :base}]), do: buff |> Enum.reverse
  def clean_input([char | chars], [{buff, op} | parent_stack]=stack) do
    case char do
      "{" ->
        # IO.inspect {"{", parent_stack}
        clean_input(chars, [{[char], char} | stack])
      "}" ->
        updated_buff = if op == :discard, do: ["0"], else: [char | buff]
        # IO.inspect {"}", updated_buff, stack}
        [{parent_buff, parent_op} | grandparent_stack] = parent_stack
        updated_parent_stack = [{updated_buff ++ parent_buff, parent_op} | grandparent_stack]
        clean_input(chars, updated_parent_stack)
      _ ->
        if op == :discard do
          clean_input(chars, [{[], :discard} | parent_stack])
        else
          new_buff = [char | buff]
          # IO.inspect {op, new_buff}
          if op == "{" && Enum.take(new_buff, 6) == ~w(" d e r " :) do
            clean_input(chars, [{[], :discard} | parent_stack])
          else
            clean_input(chars, [{new_buff, op} | parent_stack])
          end
        end
    end
  end

  def sum_input(input) do
    Regex.scan(~r/-?[\d]+/, input)
    |> Enum.reduce(0, fn [str], acc -> acc + String.to_integer(str) end)
  end
end


result = [
  ~s([1,2,3]),
  ~s([1,{"c":"red","b":2},3]),
  ~s({"d":"red","e":[1,2,3,4],"f":5}),
  ~s([1,"red",5]),
]
|> Enum.map(&Abacus.clean_input/1)
|> Enum.map(&Abacus.sum_input/1)

^result = [
  6, 
  4, 
  0, 
  6,
]

result = Path.join(__DIR__, "input.txt")
|> File.read!
|> Abacus.clean_input
|> Abacus.sum_input
|> IO.inspect

^result = 87842
