defmodule LookAndSay do
  
  def say(digits) do
    [digit | str] = "#{digits}" |> String.split("", trim: true)
    say(str, {digit, 1}, [])
  end
  def say([], {digit, count}, acc) do
    acc = [acc, "#{count}#{digit}"]
    IO.chardata_to_string(acc)
  end
  def say([new_digit | str], {digit, count}, acc) do
    if new_digit == digit do
      say(str, {digit, count+1}, acc)
    else
      say(str, {new_digit, 1}, [acc, "#{count}#{digit}"])
    end
  end
end

result =
~w(
1
11
21
1211
111221
)
|> Enum.map(&LookAndSay.say/1)

^result = ~w(
11
21
1211
111221
312211
)

result = 1..40
|> Enum.reduce(1321131112, fn _i, acc -> LookAndSay.say(acc) end)
|> String.length
|> IO.inspect

^result = 492982
