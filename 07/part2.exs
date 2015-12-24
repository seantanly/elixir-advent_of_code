defmodule Circuit do

  def eval(circuit, cache \\ %{}) do
    circuit
    |> Enum.reduce(cache, fn {wire, _lhs}, cache ->
      {_val, cache} = eval(circuit, cache, wire)
      cache
    end)
  end
  def eval(_circuit, cache, k) when is_integer(k), do: {k, cache}
  def eval(circuit, cache, k) do
    res = Map.get(cache, k)
    if res do
      {res, cache}
    else
      lhs = Map.get(circuit, k)
      case lhs do
        {op} ->
          {res, cache} = eval(circuit, cache, op)
          cache = Map.put(cache, k, res)
          {res, cache}
        {func, ops} ->
          {vals, cache} = ops
          |> Enum.reduce({[], cache}, fn op, {vals, cache} ->
            {val, cache} = eval(circuit, cache, op)
            {vals ++ [val], cache}
          end)
          res = :erlang.apply(func, vals) |> normalize
          cache = Map.put(cache, k, res)
          {res, cache}
        _ ->
          raise "Unknown lhs: #{inspect lhs}"
      end
    end
  end

  def normalize(res) when res < 0, do: res + 65536
  def normalize(res), do: res

  def operator_func(gate) do
    case gate do
      "AND" -> &:erlang.band/2
      "OR" -> &:erlang.bor/2
      "LSHIFT" -> &:erlang.bsl/2
      "RSHIFT" -> &:erlang.bsr/2
      "NOT" -> &:erlang.bnot/1
      _ -> raise "Unknown gate: #{inspect gate}"
    end
  end

  def operand(w) do
    case Integer.parse(w) do
      :error -> w
      {int, _} -> int
    end
  end
end

result = Path.join(__DIR__, "input.txt")
|> File.read!
|> String.split("\n", trim: true)
|> Enum.reduce(%{}, fn instr, circuit ->
  case String.split(instr," ", trim: true) do
    [signal, "->", wire] ->
      Map.put(circuit, wire, {Circuit.operand(signal)})
    [wire1, gate, wire2, "->", wire] ->
      Map.put(circuit, wire, {Circuit.operator_func(gate), [Circuit.operand(wire1), Circuit.operand(wire2)]})
    [gate, wire1, "->", wire] ->
      Map.put(circuit, wire, {Circuit.operator_func(gate), [Circuit.operand(wire1)]})
    _ ->
      raise "Unknown instr: #{inspect instr}"
  end
end)
|> Circuit.eval(%{"b" => 3176})
# |> IO.inspect
|> Map.get("a")
|> IO.inspect

^result = 14710
