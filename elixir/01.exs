defmodule Day01 do
  # Read input as lines
  defp read_input do
    File.read!(Path.expand("../inputs/input01.txt"))
    |> String.split("\n")
  end

  @doc """
  Extract first and last digit of each line
  Concatenate those 2 digits per line, and sum lines
  """
  def part1 do
    read_input()
    |> Enum.map(fn line ->
      [
        Regex.run(~r/^\D*(\d)/, line),
        Regex.run(~r/(\d)\D*$/, line)
      ]
      |> Enum.map(fn [_, digit] -> digit end)
    end)
    |> Enum.map(fn [a, b] -> String.to_integer("#{a}#{b}") end)
    |> Enum.sum
    |> IO.inspect(label: "P1")
  end

  @doc """
  Extract first and last "digit" of each line
  one, two, three, four, five, six, seven, eight, and nine also count as valid "digits"
  Concatenate per line, and sum lines
  """
  def part2 do
    read_input()
        |> Enum.map(fn line ->
      [
        Regex.run(~r/(one|two|three|four|five|six|seven|eight|nine|\d)/, line),
        Regex.run(~r/(eno|owt|eerht|ruof|evif|xis|neves|thgie|enin|\d)/, String.reverse(line))
      ]
      |> Enum.with_index
      |> Enum.map(fn {[_, digit], i} ->
        if rem(i, 2) == 0, do: digit, else: String.reverse(digit)
      end)
      |> Enum.map(fn digit ->
        case digit do
          "one" -> 1
          "two" -> 2
          "three" -> 3
          "four" -> 4
          "five" -> 5
          "six" -> 6
          "seven" -> 7
          "eight" -> 8
          "nine" -> 9
          _ -> digit
        end
      end)
    end)
    |> Enum.map(fn [a, b] -> String.to_integer("#{a}#{b}") end)
    |> Enum.sum
    |> IO.inspect(label: "P2")
  end
end

# P1: 53194
# P2: 54249
