defmodule Miner do
  def find(key, number \\ 1) do
    res = "#{key}#{number}" |> :erlang.md5 |> Base.encode16
    if String.starts_with?(res, "00000"), do: number, else: find(key, number + 1)
  end
end

result = Miner.find("ckczppom")
|> IO.inspect

^result = 117946
