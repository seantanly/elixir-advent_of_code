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

  def calc_distances(specs, time) do
    for {deer, move_speed, move, rest} <- specs do
      Stream.cycle([{move_speed, move}, {0, rest}])
      |> Enum.reduce_while({time, 0}, fn {speed, duration}, {time_left, distance} ->
        if time_left >= duration do
          acc = {time_left - duration, distance + (speed * duration)}
          {:cont, acc}
        else
          acc = {0, distance + (speed * time_left)}
          {:halt, acc}
        end
      end)
      |> (fn {_, distance} -> {deer, distance} end).()
    end
  end

end
result =
"""
Comet can fly 14 km/s for 10 seconds, but then must rest for 127 seconds.
Dancer can fly 16 km/s for 11 seconds, but then must rest for 162 seconds.
"""
|> Reindeer.parse_specs
|> Reindeer.calc_distances(1000)
|> Enum.max_by(&elem(&1, 1))

^result = {"Comet", 1120}


result = Path.join(__DIR__, "input.txt")
|> File.read!
|> Reindeer.parse_specs
|> Reindeer.calc_distances(2503)
|> Enum.max_by(&elem(&1, 1))
|> IO.inspect

^result = {"Vixen", 2660}
