detected_specs = %{
  children: 3,
  cats: 7,
  samoyeds: 2,
  pomeranians: 3,
  akitas: 0,
  vizslas: 0,
  goldfish: 5,
  trees: 3,
  cars: 2,
  perfumes: 1,
}

aunt_specs_map = Path.join(__DIR__, "input.txt")
|> File.read!
|> String.split("\n", trim: true)
|> Enum.reduce(%{}, fn input, specs->
  [person, attrs] = String.split(input, ": ", parts: 2)
  [_, aunt_num] = String.split(person, " ")
  attrs_map = attrs |> String.split(", ") |> Enum.reduce(%{}, fn kv, acc->
    [k, v] = String.split(kv, ": ")
    acc |> Map.put(String.to_atom(k), String.to_integer(v))
  end)
  specs |> Map.put(String.to_integer(aunt_num), attrs_map)
end)

result = aunt_specs_map
|> Enum.filter(fn {_aunt_num, aunt_spec} -> 
  detected_specs |> Enum.all?(fn {k, detected_val} ->
    case aunt_spec[k] do
      aunt_val when aunt_val in [nil, detected_val] -> true
      _ -> false
    end
  end)
end)
|> IO.inspect
|> Enum.at(0)
|> elem(0)
|> IO.inspect

^result = 373
