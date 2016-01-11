defmodule M do

  def exec(instrs), do: exec(instrs, %{"a" => 0, "b" => 0}, 0)
  def exec(instrs, registers, ptr) when ptr >= length(instrs), do: registers
  def exec(instrs, registers, ptr) do
    instr = Enum.at(instrs, ptr)
    # IO.inspect {ptr, instr, registers}
    instr
    |> String.split(" ", trim: true)
    |> case do
      ["hlf", reg] -> exec(instrs, Map.update!(registers, reg, &trunc(&1 / 2)), ptr + 1)
      ["tpl", reg] -> exec(instrs, Map.update!(registers, reg, &(&1 * 3)), ptr + 1)
      ["inc", reg] -> exec(instrs, Map.update!(registers, reg, &(&1 + 1)), ptr + 1)
      ["jmp", offset] -> exec(instrs, registers, ptr + String.to_integer(offset))
      ["jie", regc, offset] ->
        reg = String.replace_suffix(regc, ",", "")
        if rem(registers[reg], 2) == 0 do
          exec(instrs, registers, ptr + String.to_integer(offset))
        else
          exec(instrs, registers, ptr + 1)
        end
      ["jio", regc, offset] ->
        reg = String.replace_suffix(regc, ",", "")
        if registers[reg] == 1 do
          exec(instrs, registers, ptr + String.to_integer(offset))
        else
          exec(instrs, registers, ptr + 1)
        end
      unknown -> raise "Unknown instr: #{inspect unknown}"
    end
  end

end

result = Path.join(__DIR__, "input.txt")
|> File.read!
|> String.split("\n", trim: true)
|> M.exec(%{"a" => 1, "b" => 0}, 0)
|> IO.inspect
|> Map.get("b")
|> IO.inspect

^result = 334
