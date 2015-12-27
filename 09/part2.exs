defmodule Finder do

  def location_pair(loc1, loc2), do: [loc1, loc2] |> Enum.sort

  def parse_data(data) do
    {dist_map, locations} =
    data
    |> Enum.reduce({%{}, MapSet.new}, fn str, {dist_map, locations} ->
      [loc1, "to", loc2, "=", dist] = String.split(str, " ", trim: true)
      {Map.put(dist_map, location_pair(loc1, loc2), String.to_integer(dist)), locations |> Set.put(loc1) |> Set.put(loc2)}
    end)
    {dist_map, Set.to_list(locations) |> Enum.sort}
  end

  def find_longest(dist_map, location_list) do
    {reversed_path, dist} = find_longest(dist_map, location_list, [], 0)
    {reversed_path, dist}
  end
  def find_longest(_dist_map, [], path, path_dist), do: {path, path_dist}
  def find_longest(dist_map, location_list, path, path_dist) do
    location_list
    |> Enum.map(fn location ->
      new_location_list = List.delete(location_list, location)
      last_location = List.first(path)
      dist = if !last_location, do: 0, else: Map.get(dist_map, location_pair(last_location, location))
      find_longest(dist_map, new_location_list, [location | path], dist + path_dist)
    end)
    |> Enum.sort_by(&(elem(&1, 1)), &>/2)
    |> List.first
  end

  def calc_result(input) do
    {dist_map, location_list} =
    input
    |> String.split("\n", trim: true)
    |> Finder.parse_data

    {_path, result} = Finder.find_longest(dist_map, location_list)
    # |> IO.inspect

    result
  end

end

result =
"""
London to Dublin = 464
London to Belfast = 518
Dublin to Belfast = 141
"""
|> Finder.calc_result
|> IO.inspect

^result = 982

result =
Path.join(__DIR__, "input.txt")
|> File.read!
|> Finder.calc_result
|> IO.inspect

^result = 804
