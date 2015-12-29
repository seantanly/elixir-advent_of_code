defmodule Reindeer do

  def parse_specs(inputs) do
    inputs
    |> String.split("\n", trim: true)
    |> Enum.reduce([], fn input, specs_acc ->
      [
        _, deer, speed, move, rest
      ] = Regex.run(~r/(\w+) can fly (\d+) km\/s for (\d+) seconds, but then must rest for (\d+) seconds./, input)
      [{deer, String.to_integer(speed), String.to_integer(move), String.to_integer(rest)} | specs_acc]
    end)
  end

  def calc_final_points(specs, time) do
    IO.puts "time: #{time}"
    # prepare data structure
    data = specs |> Enum.reduce(%{}, fn {deer, speed, move, rest}, data_acc ->
      data_acc |> Map.put(deer, %{
        move_range: 0..(move - 1),
        move_speed: speed,
        rest_range: move..(move + rest - 1),
        rest_speed: 0,
        range_size: move + rest,
        distance: 0,
        points: 0,
      })
    end)

    0..(time-1) |> Enum.reduce(data, fn cur_time, data_acc ->
      # calc distance
      updated_distance_data = data_acc |> Enum.reduce(%{}, fn {deer, deer_spec}, data_acc2 ->
        ptr = rem(cur_time, deer_spec[:range_size])
        cond do
          ptr in deer_spec[:move_range] -> 
            updated_deer_spec = Map.put(deer_spec, :distance, deer_spec[:distance] + deer_spec[:move_speed])
            data_acc2 |> Map.put(deer, updated_deer_spec)
          ptr in deer_spec[:rest_range] -> 
            updated_deer_spec = Map.put(deer_spec, :distance, deer_spec[:distance] + deer_spec[:rest_speed])
            data_acc2 |> Map.put(deer, updated_deer_spec)
        end
      end)
      # calc points
      updated_points_data = updated_distance_data
      |> Enum.group_by(fn {_deer, deer_spec} -> deer_spec[:distance] end)
      |> Enum.max_by(fn {distance, _deer_spec_list} -> distance end)
      |> elem(1)
      |> Enum.reduce(updated_distance_data, fn {deer, deer_spec}, data_acc ->
        updated_deer_spec = deer_spec |> Map.put(:points, deer_spec[:points] + 1)
        data_acc |> Map.put(deer, updated_deer_spec)
      end)

      updated_points_data
    end)
  end

end

result =
"""
Comet can fly 14 km/s for 10 seconds, but then must rest for 127 seconds.
Dancer can fly 16 km/s for 11 seconds, but then must rest for 162 seconds.
"""
|> Reindeer.parse_specs
|> Reindeer.calc_final_points(1000)
|> Enum.reduce(%{}, fn {deer, deer_spec}, acc -> acc |> Map.put(deer, deer_spec[:points]) end)
|> IO.inspect

^result = %{"Dancer" => 689, "Comet" => 312}


result = Path.join(__DIR__, "input.txt")
|> File.read!
|> Reindeer.parse_specs
|> Reindeer.calc_final_points(2503)
|> Enum.map(fn {deer, deer_specs} -> {deer, deer_specs[:points]} end)
|> Enum.max_by(&elem(&1, 1))
|> IO.inspect

^result = {"Blitzen", 1256}
