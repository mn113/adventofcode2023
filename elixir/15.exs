defmodule Day15 do

  # Read input and split
  defp read_input do
    File.read!(Path.expand("../inputs/input15.txt"))
    |> String.split(",", trim: true)
  end

  defp hash(str) do
    str
    |> String.to_charlist
    |> Enum.reduce(0, fn val, acc ->
      rem(17 * (acc + val), 256)
     end)
  end

  defp parse_instr(str) do
    Regex.named_captures(~r/^(?<label>[a-z]+)(?<op>[=-])(?<foc>\d*)$/, str)
    |> then(fn captures ->
      %{
        :box => hash(captures["label"]),
        :label => captures["label"],
        :op => captures["op"],
        :foc => (
          if captures["foc"] == "",
            do: nil,
            else: String.to_integer(captures["foc"])
        )
      }
    end)
  end

  defp allocate_to_boxes(instrs) do
    instrs
    |> Enum.reduce(%{}, fn str, acc ->
      m = parse_instr(str)
      case m[:op] do
        "=" ->
          lens_tup = {m[:label], m[:foc]}
          Map.update(acc, m[:box], [lens_tup], fn lst ->
            index = Enum.find_index(lst,  &(elem(&1,0) == m[:label]))
            if is_nil(index),
              # addition (of tuple)
              do: lst ++ [lens_tup],
              # replacement
              else: List.replace_at(lst, index, lens_tup)
          end)
        "-" -> Map.update(acc, m[:box], [], fn lst ->
          # deletion
          Enum.reject(lst, &(elem(&1,0) == m[:label]))
        end)
      end
    end)
  end

  # Sum the lens powers
  defp calculate_power(boxmap) do
    boxmap
    |> Enum.map(fn {box, lst} -> lst
      |> Enum.with_index(1)
      |> Enum.map(fn {{_, foc},i} -> (1+box) * i * foc end)
      |> Enum.sum
    end)
    |> Enum.sum
  end

  @doc """
  Find sum of hashed instructions
  """
  def part1 do
    read_input()
    |> Enum.map(&(hash(&1)))
    |> Enum.sum
    |> IO.inspect(label: "P1")
  end

  @doc """
  Find focusing power after allocating all lenses to their boxes
  """
  def part2 do
    read_input()
    |> allocate_to_boxes()
    |> calculate_power()
    |> IO.inspect(label: "P2")
  end
end

# P1: 506437
# P2: 288521
