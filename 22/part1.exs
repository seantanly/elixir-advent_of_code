defmodule M do

  @spell_specs %{
    "Magic Missile" => %{
      instant: %{player_mp: -53, boss_hp: -4},
    },
    "Drain" => %{
      instant: %{player_mp: -73, boss_hp: -2, player_hp: 2},
    },
    "Shield" => %{
      instant: %{player_mp: -113},
      effect: {6, %{player_armor: 7}},
    },
    "Poison" => %{
      instant: %{player_mp: -173},
      effect: {6, %{boss_hp: -3}},
    },
    "Recharge" => %{
      instant: %{player_mp: -229},
      effect: {5, %{player_mp: 101}},
    },
  }

  @base_stats %{player_armor: 0}

  # return {costs, winning_moves}
  def fight(p_hp, p_mp, b_hp, b_dmg) do
    start_state = %{player_hp: p_hp, player_mp: p_mp, boss_hp: b_hp, boss_dmg: b_dmg, effects: %{}, current_turn: 0}
    {costs, winning_moves} = do_player_turn(start_state, {0, []}, {:infinity, nil})
    {costs, winning_moves |> List.wrap |> Enum.reverse}
  end

  defp do_player_turn(state, {costs, moves}=moves_info, {wcosts, _wmoves}=winning_moves_info) do
    # IO.inspect {:player_turn, moves_info, winning_moves_info, state}
    with \
      new_state      = do_effects(state),
      :ok           <- check_state(new_state),
      {:ok, spells} <- get_possible_player_spells(new_state, costs, wcosts)
    do
      winning_moves_result =
        spells
        |> Enum.reduce(winning_moves_info, fn spell, winning_moves_info_acc ->
          with \
            new_state  = do_spell(new_state, spell),
            :ok       <- check_state(new_state)
          do
            {:end_player_turn, new_state}
            # |> IO.inspect
          end
          |> handle_state({spell_mp_costs(spell) + costs, [spell | moves]}, winning_moves_info_acc)
        end)

      {:player_result, winning_moves_result}
    end
    |> handle_state(moves_info, winning_moves_info)
  end

  defp do_boss_turn(state, moves_info, winning_moves_info) do
    # IO.inspect {:boss_turn, moves_info, winning_moves_info, state}
    with \
      new_state  = do_effects(state),
      :ok       <- check_state(new_state),
      new_state  = do_boss_damage(new_state),
      :ok       <- check_state(new_state)
    do
      {:end_boss_turn, new_state}
      # |> IO.inspect
    end
    |> handle_state(moves_info, winning_moves_info)
  end

  defp check_state(state) do
    cond do
      state[:boss_hp] <= 0 -> :boss_dead
      state[:player_hp] <= 0 -> :player_dead
      true -> :ok
    end
  end

  defp handle_state(result, moves_info, winning_moves_info) do
    case result do
      :boss_dead -> Enum.min_by([moves_info, winning_moves_info], &elem(&1, 0))
      :player_dead -> winning_moves_info
      :player_no_spell -> winning_moves_info
      {:player_result, winning_moves_result} -> Enum.min_by([winning_moves_result, winning_moves_info], &elem(&1, 0))
      {:end_player_turn, new_state} -> new_state |> end_turn |> do_boss_turn(moves_info, winning_moves_info)
      {:end_boss_turn, new_state} -> new_state |> end_turn |> do_player_turn(moves_info, winning_moves_info)
      unknown -> raise "Unknown state: #{inspect unknown}"
    end
  end

  # return {:ok, spells} or :player_no_spell
  defp get_possible_player_spells(state, cur_costs, winning_costs) do
    @spell_specs
    |> Map.keys #spell names
    |> Enum.reject(&(spell_mp_costs(&1) > state[:player_mp]))
    |> Enum.reject(&(cur_costs && winning_costs && spell_mp_costs(&1) + cur_costs >= winning_costs))
    |> Enum.reject(fn spell_name ->
      end_turn = get_in(state, [:effects, spell_name]) || 0
      end_turn > state[:current_turn]
    end)
    |> case do
      [] -> :player_no_spell
      spells -> {:ok, spells}
    end
  end

  defp end_turn(state), do: Map.update!(state, :current_turn, &(&1 + 1))

  defp spell_mp_costs(spell_name), do: @spell_specs |> get_in([spell_name, :instant, :player_mp]) |> abs

  defp do_changes(state, nil), do: state
  defp do_changes(state, changes) do
    changes
    |> Enum.reduce(state, fn {k, v}, state_acc ->
      Map.update!(state_acc, k, &(&1 + v))
    end)
  end

  defp add_effect(state, _spell_name, nil), do: state
  defp add_effect(state, spell_name, effect) do
    {spell_turns, _changes} = effect
    update_in(state, [:effects, spell_name], fn _ -> state[:current_turn] + spell_turns end)
  end

  defp remove_effect(state, spell_name) do
    state |> update_in([:effects], &Map.delete(&1, spell_name))
  end

  # execute effects
  defp do_effects(state) do
    state = state |> Map.merge(@base_stats)
    state[:effects]
    |> Enum.reduce(state, fn {spell_name, spell_turn_end}, state_acc ->
      state_acc = if state_acc[:current_turn] > spell_turn_end do
        state_acc
      else
        changes = @spell_specs |> Map.fetch!(spell_name) |> Map.fetch!(:effect) |> elem(1)
        do_changes(state_acc, changes)
      end
      if spell_turn_end > state_acc[:current_turn], do: state_acc, else: remove_effect(state_acc, spell_name)
    end)
  end

  # execute spell
  defp do_spell(state, spell_name) do
    spell_spec = Map.fetch!(@spell_specs, spell_name)
    state
    |> do_changes(spell_spec[:instant])
    |> add_effect(spell_name, spell_spec[:effect])
  end

  defp do_boss_damage(state) do
    state
    |> Map.update!(:player_hp, fn player_hp ->
      dmg = Enum.max([state[:boss_dmg] - state[:player_armor], 1])
      player_hp - dmg
    end)
  end

end

# Tests
{_costs, winning_moves} = M.fight(10, 250, 13, 8)
|> IO.inspect

^winning_moves = ["Poison", "Magic Missile"]

{_costs, winning_moves} = M.fight(10, 250, 14, 8)
|> IO.inspect

^winning_moves = ["Recharge", "Shield", "Drain", "Poison", "Magic Missile"]
IO.puts "Tests completed successfully."

# Part 1
{b_hp, b_dmg} =
  Path.join(__DIR__, "input.txt")
  |> File.read!
  |> String.split("\n", trim: true)
  |> Enum.reduce(%{}, fn str, acc ->
    [name, val] = String.split(str, ": ", trim: true)
    acc |> Map.put(name, String.to_integer(val))
  end)
  |> IO.inspect
  |> (fn attrs -> {attrs["Hit Points"], attrs["Damage"]} end).()

{result, _wmoves} = M.fight(50, 500, b_hp, b_dmg)
|> IO.inspect

^result = 1824
