defmodule Table do

  def val(op, pts) do
    pts = String.to_integer(pts)
    case op do
      "gain" -> pts
      "lose" -> -pts
      _ -> raise "Unknown op: #{inspect op}"
    end
  end
  def parse_inputs(inputs) do
    inputs
    |> String.split("\n", trim: true)
    |> Enum.reduce({%{}, MapSet.new}, fn input, {rules_map, persons} ->
       [_, p1, op, pts, p2] = ~r/(\w+) would (\w+) (\d+) happiness units by sitting next to (\w+)\./
       |> Regex.run(input)
       {Map.put(rules_map, {p1, p2}, val(op, pts)), persons |> Set.put(p1) |> Set.put(p2)}
    end)
    |> (fn {rules_map, persons_set} ->
      {rules_map, persons_set |> Set.to_list} 
    end).()
  end

  def calc_happiness(rules_map, seatings) do
    seatings_length = length(seatings)
    0..(seatings_length - 1)
    |> Enum.reduce(0, fn i, acc ->
      p0 = Enum.at(seatings, rem(i - 1, seatings_length))
      p1 = Enum.at(seatings, rem(i, seatings_length))
      p2 = Enum.at(seatings, rem(i + 1, seatings_length))
      acc + Map.get(rules_map, {p1, p0}) + Map.get(rules_map, {p1, p2})
    end)
  end

  def max_happiness({rules_map, persons}) do
    do_max_happiness(rules_map, persons, [])
    |> IO.inspect
    |> elem(1)
  end
  def do_max_happiness(rules_map, [], seatings_acc), do: {seatings_acc, calc_happiness(rules_map, seatings_acc)}
  def do_max_happiness(rules_map, persons, seatings_acc) do
    for i <- 0..(length(persons) - 1) do
      person = Enum.at(persons, i)
      do_max_happiness(rules_map, List.delete(persons, person), [person | seatings_acc])
    end
    |> Enum.max_by(fn {_seatings, happiness} -> happiness end)
  end

end

result =
"""
Alice would gain 54 happiness units by sitting next to Bob.
Alice would lose 79 happiness units by sitting next to Carol.
Alice would lose 2 happiness units by sitting next to David.
Bob would gain 83 happiness units by sitting next to Alice.
Bob would lose 7 happiness units by sitting next to Carol.
Bob would lose 63 happiness units by sitting next to David.
Carol would lose 62 happiness units by sitting next to Alice.
Carol would gain 60 happiness units by sitting next to Bob.
Carol would gain 55 happiness units by sitting next to David.
David would gain 46 happiness units by sitting next to Alice.
David would lose 7 happiness units by sitting next to Bob.
David would gain 41 happiness units by sitting next to Carol.
"""
|> Table.parse_inputs
|> Table.max_happiness
|> IO.inspect

^result = 330


result = Path.join(__DIR__, "input.txt")
|> File.read!
|> Table.parse_inputs
|> Table.max_happiness
|> IO.inspect

^result = 709
