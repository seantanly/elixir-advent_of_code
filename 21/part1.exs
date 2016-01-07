defmodule M do
  defmodule N do
    def parse_stats(strs) do
      strs
      |> String.split("\n", trim: true)
      |> Enum.split(1) |> elem(1) # discard headings
      |> Enum.map(fn str ->
        {[name], stats_list} = str |> String.split(~r/[ ]{2,}/, trim: true) |> Enum.split(1)
        [name | (stats_list |> Enum.map(&String.to_integer/1))]
        |> List.to_tuple
      end)
      # |> IO.inspect
    end

    def combination(collection, k) when is_integer(k) and k >= 0 do 
      list = collection |> Enum.into([])
      list_length = Enum.count(list)
      if k > list_length do
        raise Enum.OutOfBoundsError 
      else 
        do_combination(list, list_length, k, [], [])
      end
    end
    def combination(collection, k1..k2) when k2 >= k1 do
      k1..k2 |> Enum.flat_map(fn k -> combination(collection, k) end)
    end
    defp do_combination(_, _, 0, _, _), do: [[]]
    defp do_combination(list, _, 1, _, _), do: list |> Enum.map(&([&1])) # optimization
    defp do_combination(list, list_length, k, pick_acc, acc) do
      list
      |> Stream.unfold(fn [h | t] -> {{h, t}, t} end)
      |> Enum.take(list_length)
      |> Enum.reduce(acc, fn {x, sublist}, acc ->
        sublist_length = Enum.count(sublist)
        pick_acc_length = Enum.count(pick_acc)
        if k > pick_acc_length + 1 + sublist_length do
          acc
        else
          new_pick_acc = [x | pick_acc]
          new_pick_acc_length = pick_acc_length + 1
          case new_pick_acc_length do
            ^k -> [new_pick_acc | acc]
            _  -> do_combination(sublist, sublist_length, k, new_pick_acc, acc)
          end
        end
      end)
    end
  end

  # 1 weapon
  @weapons (
    """
    Weapons:    Cost  Damage  Armor
    Dagger        8     4       0
    Shortsword   10     5       0
    Warhammer    25     6       0
    Longsword    40     7       0
    Greataxe     74     8       0
    """
    |> N.parse_stats
    |> N.combination(1)
    # |> IO.inspect
  )
  # 0..1 armor
  @armors (
    """
    Armor:      Cost  Damage  Armor
    Leather      13     0       1
    Chainmail    31     0       2
    Splintmail   53     0       3
    Bandedmail   75     0       4
    Platemail   102     0       5
    """
    |> N.parse_stats
    |> N.combination(0..1)
    # |> IO.inspect
  )
  # 0..2 rings
  @rings (
    """
    Rings:      Cost  Damage  Armor
    Damage +1    25     1       0
    Damage +2    50     2       0
    Damage +3   100     3       0
    Defense +1   20     0       1
    Defense +2   40     0       2
    Defense +3   80     0       3
    """
    |> N.parse_stats
    |> N.combination(0..2)
    # |> IO.inspect
  )

  def parse_monster_stats(strs) do
    for str <- strs, into: %{} do
      [_, name, stat] = Regex.run(~r/(\w+): (\d+)/, str)
      {name, String.to_integer(stat)}
    end
  end

  def find_equips(monster_stats, player_points) do
    for wpn <- @weapons, amr <- @armors, rings <- @rings do
      equips = wpn ++ amr ++ rings
      equip_stats =
        equips
        |> Enum.reduce({0, 0, 0}, fn item, acc ->
          (for i <- 0..2, do: elem(item, i + 1) + elem(acc, i))
          |> List.to_tuple
        end)
      {equip_stats, equips}
    end
    |> Enum.filter(fn {equip_stats, _} -> player_win?(player_points, equip_stats, monster_stats) end)
    |> Enum.min_by(fn {equip_stats, _} -> elem(equip_stats, 0) end)
  end

  def player_win?(player_points, equip_stats, monster_stats) do
    {_, player_damage, player_armor} = equip_stats
    player_rounds =
      (monster_stats["Points"] / Enum.max([player_damage - monster_stats["Armor"], 1]))
      |> Float.ceil
    monster_rounds =
      (player_points / Enum.max([monster_stats["Damage"] - player_armor, 1]))
      |> Float.ceil

    player_rounds <= monster_rounds
  end

end

monster_stats = Path.join(__DIR__, "input.txt")
|> File.read!
|> String.split("\n", trim: true)
|> M.parse_monster_stats
|> IO.inspect

result = M.find_equips(monster_stats, 100)
|> IO.inspect
|> elem(0) |> elem(0)
|> IO.inspect

^result = 78
