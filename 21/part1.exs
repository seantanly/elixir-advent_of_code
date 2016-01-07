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

    def permutate(list, r1..r2, inert_func \\ fn _i -> nil end) do
      # introduce inert factors into the base set for permutating less than max combinations
      (for i <- 1..(r2 - r1), r2 > r1, do: inert_func.(i)) ++ list
      |> do_permutate(r2, [], [])
    end
    # Permuate nCr
    def do_permutate(list, 1, _, _), do: list
    def do_permutate(list, r, pick_acc, acc) do
      list
      |> Stream.unfold(fn [h | t] -> {{h, t}, t} end)
      |> Enum.take(length(list))
      |> Enum.filter(fn {_x, nlist} -> length(pick_acc) + 1 + length(nlist) >= r end)
      |> Enum.reduce(acc, fn {x, nlist}, acc ->
        pick_acc = [x | pick_acc]
        case length(pick_acc) do
          ^r -> [pick_acc | acc]
          _  -> do_permutate(nlist, r, pick_acc, acc)
        end
      end)
    end
  end

  @inert_item_func &({"None #{&1}", 0, 0, 0})
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
    |> N.permutate(1..1, @inert_item_func)
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
    |> N.permutate(0..1, @inert_item_func)
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
    |> N.permutate(0..2, @inert_item_func)
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
      equips = [wpn] ++ [amr] ++ rings
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
