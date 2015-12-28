defmodule Password do
  @invalid_chars [?i, ?o, ?l]

  @chars_start ?a
  @chars_end ?z
  @chars_base_length @chars_end - @chars_start + 1

  def inc_char(char, amt) do
    base = char - @chars_start + amt
    val = rem(base, @chars_base_length) + @chars_start
    if val in @invalid_chars do
      inc_char(char, amt + 1)
    else
      carry = div(base, @chars_base_length)
      {val, carry}
    end
  end

  def clean_input(chars), do: clean_input(chars, [], false) |> Enum.reverse
  def clean_input([], acc, _), do: acc
  def clean_input([_char | chars], acc, _reset=true), do: clean_input(chars, [@chars_start | acc], true)
  def clean_input([char | chars], acc, false) do
    if char in @invalid_chars do
      {new_char, carry} = inc_char(char, 1)
      acc = if carry == 0, do: acc, else: inc(acc, carry, []) |> Enum.reverse
      clean_input(chars, [new_char | acc], true)
    else
      clean_input(chars, [char | acc], false)
    end
  end

  def inc(chars) do
    inc(Enum.reverse(chars), 1, [])
  end
  def inc([], carry, acc) do
    if carry == 0 do
      acc
    else
      {new_char, carry} = inc_char(@chars_start, carry - 1)
      inc([], carry, [new_char | acc])
    end
  end
  def inc([char|chars], carry, acc) do
    {new_char, carry} = inc_char(char, carry)
    inc(chars, carry, [new_char | acc])
  end

  def contains_invalid_chars?(chars) do
    {:ok, regex} = Regex.compile("[#{@invalid_chars}]")
    chars |> IO.chardata_to_string |> String.match?(regex)
  end

  def contains_straight_of_three?([char | chars]), do: contains_straight_of_three?(chars, {char, 1})
  def contains_straight_of_three?(_, {_prev, count}) when count == 3, do: true
  def contains_straight_of_three?([], _), do: false
  def contains_straight_of_three?([char | chars], {prev, count}) do
    if char == prev + 1 do
      contains_straight_of_three?(chars, {char, count + 1})
    else
      contains_straight_of_three?(chars, {char, 1})
    end
  end

  def contains_two_different_pairs?(chars), do: contains_two_different_pairs?(chars, [], 0)
  def contains_two_different_pairs?(_, _, count) when count >= 2, do: true
  def contains_two_different_pairs?([], _, _), do: false
  def contains_two_different_pairs?(chars, found_pairs, count) do
    {pair, char_rest} = Enum.split(chars, 2)
    case pair do
      [x, x] ->
        if x in found_pairs do
          contains_two_different_pairs?(char_rest, found_pairs, count)
        else
          contains_two_different_pairs?(char_rest, [x | found_pairs], count + 1)
        end
      _ ->
        [_ | char_rest] = chars
        contains_two_different_pairs?(char_rest, found_pairs, count)
    end
  end

  def next_password(cur), do: cur |> clean_input |> do_next_password
  def do_next_password(cur) do
    new = inc(cur)
    with false <- contains_invalid_chars?(new),
      true <- contains_straight_of_three?(new),
      true <- contains_two_different_pairs?(new)
    do
      :ok
    end
    |> case do
      :ok -> new
      _ -> next_password(new)
    end
  end
end

result = [
'abcdefgh',
'ghijklmn',
]
|> Enum.map(&Password.next_password/1)
|> IO.inspect

^result = [
'abcdffaa',
'ghjaabcc',
]

result = 'hepxcrrq'
|> Password.next_password
|> IO.inspect

^result = 'hepxxyzz'

