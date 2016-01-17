defmodule M do
  @moduledoc """
  Referencing : https://www.reddit.com/r/adventofcode/comments/3xflz8/day_19_solutions/cy4etju
  Thanks to analysis by askalski, if not this would not have been possible. Runtime < 1 sec :D

  You can think of Rn Y Ar as the characters ( , )

  The productions are mainly
  1. X => XX
  2. X => X(X) | X(X,X) | X(X,X,X)

  ----

  There is no need to worry about same RHS mapping to diff LHS. RHS are all unique.
  There are no production rules that arbitary introduce ( , or ) without them being a set.

  Not using the arithmetic formula solution shown in the reddit thread, this solution works by reducing the final molecule
  via reducing away all `(,)` in the first pass, and subsequently reduce the result from the first pass to achieve the final
  molecule.

  For the first pass, there is the *important assumption* that there is only 1 way to reduce it, thus
  any found solution naturally optimal. As such, we will not keeping track of the actual steps for backtracing, only counting it.

  The 2nd pass, we go for reduction of XX towards the target molecule, again assuming there is only 1 optimal way to do it.

  With the assumption that the found solution is optimal, the problem search space is too huge to be fully computed.
  """


  # convert the input's Rn Y Ar to ( , ) for easier reading, and required for the code.
  def convert_input(input) do
    input
    |> String.replace("Rn", "(")
    |> String.replace("Y", ",")
    |> String.replace("Ar", ")")
  end

  # used to split out all possible molecules including the oddball molecule e which doesn't start with Caps.
  # Note the regex is slightly tricky.
  @molecule_regex ~r/[A-Z][a-df-z]{0,1}|[\(,\)]|e/
  defp to_molecules(str), do: Regex.scan(@molecule_regex, str) |> Enum.map(&List.first(&1))
  defp molecules_length(str), do: str |> to_molecules |> Enum.count

  # returns {spec_list, final}, converted to ( , )
  def parse_inputs(inputs) do
    input_lines =
      inputs
      |> convert_input
      |> String.split("\n", trim: true)

    {spec_strs, [final]} = Enum.split(input_lines, length(input_lines) - 1)
    spec_list =
      spec_strs
      |> Enum.reduce([], fn spec_str, spec_list ->
        [val, "=>", key] = String.split(spec_str, " ", trim: true)
        [{key, val} | spec_list]
      end)

    # Heuristic optimisations: Attempt biggest reduction first
    spec_list =
      spec_list
      |> Enum.sort_by(fn {k, _} -> String.length(k) end, &>/2)
      |> IO.inspect

    {spec_list, final}
  end

  def get_str_replace_combinations(str, pattern, replacement) do
    matches = :binary.matches(str, pattern) |> Enum.reverse
    Stream.map(matches, fn match ->
      :binary.replace(str, pattern, replacement, [{:scope, match}])
    end)
  end

  # custom split_by function for Enumerable.
  defp split_by(collection, func) do
    collection
    |> Enum.reduce([[]], fn ele, acc ->
      if func.(ele) do
        [[] | acc]
      else
        [last | acc] = acc
        [[ele | last] | acc]
      end
    end)
    |> Enum.map(&Enum.reverse/1)
    |> Enum.reverse
  end

  def min_steps({spec_list, str}, target) do
    # IO.inspect {:molecules_length_start, molecules_length(str)}

    {reversed_reduced_molecules, count} = do_reduce_bracket_pass(spec_list, str |> to_molecules, [], 0)
    # IO.inspect {:molecules_length_reduced, reversed_reduced_molecules |> Enum.count}

    {^target, count} = reduce_to_target(spec_list, reversed_reduced_molecules, count, target)

    count
  end

  defp do_reduce_bracket_pass(_spec_list, [], acc, count), do: {acc, count}
  defp do_reduce_bracket_pass(spec_list, [molecule | molecules], acc, count) do
    case molecule do
      ")" -> # get what's in the () and solve it to simplest form and reduce until the corresponding ( is gone.
        part = [molecule | acc]
        {part, count} = resolve_bracket(spec_list, part, count)
        do_reduce_bracket_pass(spec_list, molecules, part, count)
      _ ->
        acc = [molecule | acc]
        do_reduce_bracket_pass(spec_list, molecules, acc, count)
    end
  end

  # aim is to resolve_bracket and remove the ending ) and return the resulting part and the number of ops.
  # part is passed in reversed and should be return similarly in reversed form.
  def resolve_bracket(spec_list, part, count) do
    # IO.inspect {:resolve_bracket, part, count}

    # (X), (X,X) or (X,X,X)
    # reduce all molecules within `()` into single molecule, separated by `,` if present.
    # IO.inspect {:before_bracket_within, part, count}
    index = Enum.find_index(part, &(&1 == "("))
    molecules_within_brackets = Enum.slice(part, 1..(index-1)) # get content within ()

    {reduced_part, new_count} = reduce_within_brackets(spec_list, molecules_within_brackets, count)

    new_part = Enum.slice(part, 0..0) ++ reduced_part ++ Enum.slice(part, index..(length(part) - 1))
    # IO.inspect {:after_bracket_within, new_part, new_count}

    # match and remove the bracket (), there are 2 possibilities.
    # 1: the molecule now just beside the () can be used to reduce the () immediately.
    # 2: the molecules within the brackets needs to be reduced somewhat to match the brackets
    # So what we can do is to try reducing the (), adding 1 molecule at a time until a possible combination is reached,
    # rather than trying out the entire universe which is huge.
    index = Enum.find_index(new_part, &(&1 == "("))

    result =
      (index + 2)..(length(new_part) - 1)
      |> Enum.reduce_while(nil, fn index, acc ->
        {bracket_with_part, remaining} = Enum.split(new_part, index)
        case reduce_to_single(spec_list, bracket_with_part, new_count) do
          nil -> {:cont, acc}

          {molecule, new_count} ->
            new_part = [molecule | remaining]
            {:halt, {new_part, new_count}}
        end
      end)
    # IO.inspect {:resolve_bracket_result, result}
    result
  end

  # reduces the molecules within (,) to single molecule items.
  def reduce_within_brackets(spec_list, reversed_molecules, count) do
    {reduced_content, new_count}  = reversed_molecules
    |> split_by(&(&1 == ","))
    |> Enum.reduce({[], count}, fn reversed_molecules, {molecules_acc, count_acc} ->
      {molecule, count_acc} = reduce_to_single(spec_list, reversed_molecules, count_acc)
      {molecules_acc ++ [molecule], count_acc}
    end)
    {Enum.intersperse(reduced_content, ","), new_count}
  end

  # return first result {molecule, count} or nil if unable to do so
  def reduce_to_single(spec_list, reversed_molecules, count) do
    # IO.inspect {:reduce_to_single, reversed_molecules, count}
    reversed_molecules_str = reversed_molecules |> Enum.reverse |> Enum.join("")
    {result, _tried_set} = do_reduce_to_target_by(
      spec_list,
      reversed_molecules_str,
      count,
      &(molecules_length(&1) == 1),
      MapSet.new
    )
    # IO.inspect {:reduce_to_single_result, result}
    result
  end

  # return first result {molecule, count} or nil if unable to do so
  def reduce_to_target(spec_list, reversed_molecules, count, target) do
    # IO.inspect {:reduce_to_target, reversed_molecules, count}
    reversed_molecules_str = reversed_molecules |> Enum.reverse |> Enum.join("")
    {result, _tried_set} = do_reduce_to_target_by(
      spec_list,
      reversed_molecules_str,
      count,
      &(&1 == target),
      MapSet.new
    )
    # IO.inspect {:reduce_to_target_result, result}
    result
  end

  # work in String instead of [molecules] to make use of String manipulation functions.
  # tried_set is used to prevent endless recursion.
  # result is found when target_func/1 returns true.
  # returns {result, tried_set}
  def do_reduce_to_target_by(spec_list, str, count, target_func, tried_set) do
    if Set.member?(tried_set, str) do
      {nil, tried_set}
    else
      tried_set = tried_set |> Set.put(str)
      # IO.inspect {:do_reduce_to_target_by, str, molecules_length(str), count}
      cond do
        target_func.(str) ->
          result = {str, count}
          # IO.inspect {:reduce_to_one, result}
          {result, tried_set}
        true ->
          spec_list |> Enum.reduce_while({nil, tried_set}, fn {pattern, replacement}, {acc, tried_set_acc} ->
            # IO.inspect {:do_reduce_to_target_by_replacement, count, str, pattern, replacement}
            get_str_replace_combinations(str, pattern, replacement)
            # assume the found reduction is always optimal
            |> Enum.reduce_while({nil, tried_set_acc}, fn new_str, {acc2, tried_set_acc2} ->
              case do_reduce_to_target_by(spec_list, new_str, count + 1, target_func, tried_set_acc2) do
                {nil, tried_set_acc2} -> {:cont, {acc2, tried_set_acc2}}
                {result, tried_set_acc2} -> {:halt, {result, tried_set_acc2}}
              end
            end)
            |> case do
              {nil, tried_set_acc} -> {:cont, {acc, tried_set_acc}}
              {result, tried_set_acc} -> {:halt, {result, tried_set_acc}}
            end
          end)
          |> case do
            {nil, tried_set} -> {nil, tried_set}
            {result, tried_set} -> {result, tried_set}
          end
      end
    end
  end

end


##### TESTS #####

result =
"""
e => H
e => O
H => HO
H => OH
O => HH

HOH
"""
|> M.parse_inputs
|> M.min_steps("e")
|> IO.inspect

^result = 3

result =
"""
e => H
e => O
H => HO
H => OH
O => HH

HOHOHO
"""
|> M.parse_inputs
|> M.min_steps("e")
|> IO.inspect

^result = 6

# Generate output.txt replacing Rn Y Ar with ( , )
converted_content = Path.join(__DIR__, "input.txt")
|> File.read!
|> M.convert_input
Path.join(__DIR__, "input_converted.txt")
|> File.write(converted_content)


{spec_list, final} =
  Path.join(__DIR__, "input.txt")
  |> File.read!
  |> M.parse_inputs

# O(PBPMg)
# O(PBF)
# O(CaF)
# O(F)
# H
part = "O(PBPMg)"
result = M.min_steps({spec_list, part}, "H")
# |> IO.inspect
^result = 4

# Si(F,F)
# Ca
part = "Si(F,F)"
result = M.min_steps({spec_list, part}, "Ca")
# |> IO.inspect
^result = 1

##### END TESTS #####

# actual problem
result = M.min_steps({spec_list, final}, "e")
|> IO.inspect

^result = 207
