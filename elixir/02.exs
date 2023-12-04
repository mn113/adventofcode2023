defmodule Day02 do
  # Read input as lines
  defp read_input do
    File.read!(Path.expand("../inputs/input02.txt"))
    |> String.split("\n")
  end

  defp split_line(line), do: String.split(line, ":", trim: true)

  defp get_game_id(game_str) do
    Regex.run(~r/Game (\d+)/, game_str)
    |> Enum.at(1)
    |> String.to_integer
  end

  defp line_within_maxes?(sets_str, max_red, max_green, max_blue) do
    sets_str
    |> String.split(";", trim: true)
    |> Enum.map(fn set_str ->
      red_re = Regex.run(~r/(\d+) red/, set_str)
      green_re = Regex.run(~r/(\d+) green/, set_str)
      blue_re = Regex.run(~r/(\d+) blue/, set_str)

      red_ok = is_nil(red_re) or String.to_integer(Enum.at(red_re, 1)) <= max_red
      green_ok = is_nil(green_re) or String.to_integer(Enum.at(green_re, 1)) <= max_green
      blue_ok = is_nil(blue_re) or String.to_integer(Enum.at(blue_re, 1)) <= max_blue

      red_ok and green_ok and blue_ok
    end)
  end

  defp get_max_for_sets(sets, color) do
    {:ok, re_for_color} = Regex.compile("(\\d+) " <> color)
    sets
    |> Enum.map(fn set_str -> Regex.run(re_for_color, set_str) end)
    |> Enum.reject(&is_nil/1)
    |> Enum.map(fn [_, d] -> String.to_integer(d) end)
    |> Enum.max
  end

  defp maxes_for_line(sets_str) do
    sets = sets_str |> String.split(";", trim: true)

    max_red = get_max_for_sets(sets, "red")
    max_green = get_max_for_sets(sets, "green")
    max_blue = get_max_for_sets(sets, "blue")

    {max_red, max_green, max_blue}
  end

  @doc """
  Find sum of game ids where all sets of RGB values are within limits
  """
  def part1 do
    max_red = 12
    max_green = 13
    max_blue = 14

    read_input()
    |> Enum.map(fn line ->
      [game_str, sets_str] = split_line(line)
      game_id = get_game_id(game_str)
      line_result = line_within_maxes?(sets_str, max_red, max_green, max_blue)
      {game_id, line_result}
    end)
    |> Enum.filter(fn {_, result} -> Enum.all?(result) end)
    |> Enum.map(fn {game_id, _} -> game_id end)
    |> Enum.sum
    |> IO.inspect(label: "P1")
  end

  @doc """
  Find sum of product of minimum RGB values for all lines
  """
  def part2 do
    read_input()
    |> Enum.map(fn line ->
      [_, sets_str] = split_line(line)
      maxes_for_line(sets_str)
    end)
    |> Enum.map(fn {r, g, b} -> r * g * b end)
    |> Enum.sum
    |> IO.inspect(label: "P2")
  end
end

# P1: 2416
# P2: 63307
