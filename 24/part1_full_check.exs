defmodule Combination do

  def combine(collection, k) when is_integer(k) and k >= 0 do
    list = Enum.to_list(collection)
    list_length = Enum.count(list)
    if k > list_length do
      raise Enum.OutOfBoundsError
    else
      do_combine(list, list_length, k, [], [])
    end
  end

  defp do_combine(_list, _list_length, 0, _pick_acc, _acc), do: [[]]
  defp do_combine(list, _list_length, 1, _pick_acc, _acc), do: list |> Enum.map(&([&1])) # optimization
  defp do_combine(list, list_length, k, pick_acc, acc) do
    list
    |> Stream.unfold(fn [h | t] -> {{h, t}, t} end)
    |> Enum.take(list_length)
    |> Enum.reduce(acc, fn {x, sublist}, acc ->
      sublist_length = Enum.count(sublist)
      pick_acc_length = Enum.count(pick_acc)
      if k > pick_acc_length + 1 + sublist_length do
        acc # insufficient elements in sublist to generate new valid combinations
      else
        new_pick_acc = [x | pick_acc]
        new_pick_acc_length = pick_acc_length + 1
        case new_pick_acc_length do
          ^k -> [new_pick_acc | acc]
          _  -> do_combine(sublist, sublist_length, k, new_pick_acc, acc)
        end
      end
    end)
  end
end

# This solution added validation of 1st group by computing for a valid configuration 
# of the subsequent groups based on the remaining elements, thus producing the best possible valid answer.
defmodule M do

  def qe(pkg), do: Enum.reduce(pkg, 1, &(&1 * &2))

  def get_valid_groups(packages, group_count, group_weight), do: get_valid_groups(packages, group_count, group_weight, [])
  def get_valid_groups(packages, group_count, group_weight, groups_acc) when group_count == 1 do 
    if Enum.sum(packages) == group_weight do 
      [packages | groups_acc] 
    else 
      nil
    end
  end
  def get_valid_groups(packages, group_count, group_weight, groups_acc) do
    max_grp_length = Enum.count(packages) |> div(group_count)
    Enum.reduce_while(1..max_grp_length, nil, fn i, acc ->
      Combination.combine(packages, i)
      |> Enum.filter(&(Enum.sum(&1) == group_weight))
      # find first valid group and return it
      |> Enum.reduce_while(nil, fn grp, acc2 ->
        case get_valid_groups(packages -- grp, group_count - 1, group_weight, [grp | groups_acc]) do
          nil -> {:cont, acc2}
          groups -> {:halt, groups}
        end
      end)
      |> case do
        nil -> {:cont, acc}
        groups -> {:halt, groups} 
      end
    end)
  end
  
  def find_group_config(packages, group_count) do
    group_weight = Enum.sum(packages) |> div(group_count)
    max_grp_length = Enum.count(packages) |> div(group_count)
    Enum.reduce_while(1..max_grp_length, nil, fn i, acc ->
      Combination.combine(packages, i)
      |> Enum.filter(&(Enum.sum(&1) == group_weight))
      |> Enum.reject(&(acc && qe(acc) < qe(&1)))
      |> Enum.sort_by(&qe/1)
      |> Enum.reduce_while(nil, fn grp, acc2 -> 
        case get_valid_groups(packages -- grp, group_count - 1, group_weight) do
          nil -> {:cont, acc2}
          groups -> 
            {:halt, [grp | groups]}
        end
      end)
      |> case do
        nil -> {:cont, acc}
        groups -> {:halt, groups}
      end
    end)
  end
end

result = 
  Enum.to_list(1..5) ++ Enum.to_list(7..11)
  |> M.find_group_config(3)
  |> IO.inspect
  |> Enum.at(0)
  |> M.qe
  |> IO.inspect

^result = 99

result =
  Path.join(__DIR__, "input.txt")
  |> File.read!
  |> String.split("\n", trim: true)
  |> Enum.map(&String.to_integer/1)
  |> M.find_group_config(3)
  |> IO.inspect
  |> Enum.at(0)
  |> M.qe
  |> IO.inspect

^result = 11266889531
