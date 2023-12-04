defmodule Day03 do
  @symbols ["+", "*", "-", "/", "=", "%", "&", "$", "#", "@"]
  # ~w(+ * - / = % & $ # @)

  # Read input as lines
  defp read_input do
    File.read!(Path.expand("../inputs/input03.txt"))
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
  end

  # Loop the entire grid and build maps of number and symbol locations
  defp build_maps(grid) do
    coords = List.flatten(
      for y <- 0..(length(grid) - 1) do
        for x <- 0..(length(Enum.at(grid, 0)) - 1) do
          {x, y}
        end
      end
    )
    initial_data = %{
      numbers_map: %{},
      symbols_map: %{}
    }
    Enum.reduce(coords, initial_data, fn {y,x}, %{numbers_map: num_map, symbols_map: sym_map} ->
      row = Enum.at(grid, y)
      cond do
        Enum.at(row, x) == "." -> # dot - not stored
          %{numbers_map: num_map, symbols_map: sym_map}
        Enum.at(row, x) in @symbols -> # symbol
          %{numbers_map: num_map, symbols_map: Map.put(sym_map, {x, y}, Enum.at(row, x))}
        Enum.at(row, x) =~ ~r/\d/ and (x == 0 or Enum.at(row, x - 1) =~ ~r/\D/) -> # leading number
          full_number = row
          |> Enum.drop(x)
          |> Enum.take_while(&(&1 =~ ~r/\d/))
          |> Enum.join("")
          |> String.to_integer
          %{numbers_map: Map.put(num_map, {x, y}, full_number), symbols_map: sym_map}
        Enum.at(row, x) =~ ~r/\d/ -> # trailing number - not stored
          %{numbers_map: num_map, symbols_map: sym_map}
        true -> raise "#{x}_#{y}_#{row}"
      end
    end)
  end

  # Get all neighbors of a number string (including diagonals)
  defp get_all_neighbs({x,y}, number) do
    last_x = x + length(Integer.digits(number)) - 1
    left_edge = Enum.map([-1, 0, 1], fn i -> {x - 1, y + i} end)
    right_edge = Enum.map([-1, 0, 1], fn i -> {last_x + 1, y + i} end)
    top_edge = Enum.map(x..last_x, fn i -> {i, y - 1} end)
    bottom_edge = Enum.map(x..last_x, fn i -> {i, y + 1} end)
    left_edge ++ right_edge ++ top_edge ++ bottom_edge
  end

  # Discard numbers adjacent to symbols
  defp discard_numbers_adjacent_symbols(%{numbers_map: num_map, symbols_map: sym_map}) do
    Enum.reduce(num_map, %{}, fn {coord, number}, acc ->
      neighbs = get_all_neighbs(coord, number)
      sym_neighbs = Enum.filter(neighbs, fn coord -> Map.has_key?(sym_map, coord) end)

      if length(sym_neighbs) > 0,
        do: Map.put(acc, coord, number), # keep it
        else: acc # discard it
    end)
  end

  # Find pairs of numbers that are adjacent to a gear (*)
  defp find_gear_adjacent_pairs(%{numbers_map: num_map, symbols_map: sym_map}) do
    stars = sym_map
    |> Enum.filter(fn {_, sym} -> sym == "*" end)
    |> Enum.map(fn {coord, _} -> coord end)

    number_gear_neighbs = num_map
    |> Enum.map(fn {coord, number} ->
      gear_nb_coords = get_all_neighbs(coord, number)
      |> Enum.filter(fn coord -> Map.get(sym_map, coord) == "*" end)
      {coord, number, gear_nb_coords}
    end)
    |> Enum.reject(fn {_, _, gear_nb_coords} -> length(gear_nb_coords) == 0 end)

    # select only gears which appear twice in the last column of the map
    gears = stars
    |> Enum.filter(fn star_coord ->
      number_gear_neighbs
      |> Enum.filter(fn {_, _, gear_nb_coords} -> star_coord in gear_nb_coords end)
      |> length == 2
    end)

    number_gear_neighbs
    |> Enum.filter(fn {_, _, gear_nb_coords} -> Enum.at(gear_nb_coords, 0) in gears end)
    |> Enum.map(fn {_, number, gear_coords} -> {number, gear_coords} end)
    |> Enum.group_by(fn {_, gear_nb_coords} -> gear_nb_coords end)
  end

  @doc """
  Find sum of isolated part numbers
  """
  def part1 do
    read_input()
    |> build_maps()
    |> discard_numbers_adjacent_symbols()
    |> Map.values
    |> Enum.sum
    |> IO.inspect(label: "P1")
  end

  @doc """
  Find all gears (*) adjacent to 2 numbers
  """
  def part2 do
    read_input()
    |> build_maps()
    |> find_gear_adjacent_pairs()
    |> Map.values
    |> Enum.map(fn [{num1, _}, {num2, _}] -> num1 * num2 end)
    |> Enum.sum
    |> IO.inspect(label: "P2")
  end
end

# P1: 553079
# P2: 84363105
