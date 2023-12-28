defmodule Day25 do

  # Read input and split
  defp read_input do
    File.read!(Path.expand("../inputs/input25.txt"))
    |> String.split("\n", trim: true)
    |> Enum.map(&(String.split(&1, ~r/[\s:]+/, trim: true)))
  end

  @doc """
  Print all graph relations.
  Find 3 connections to cut, to give 2 groups.
  Graphviz will be used to identify the cuts.
  """
  def part1 do
    connections = read_input()
    |> Enum.reduce([], fn [head | tail_items], acc ->
      acc ++ Enum.map(tail_items, fn item -> {head, item} end)
    end)

    # Print dot syntax to terminal
    IO.puts "graph {"
    Enum.each(connections, fn {a, b} -> IO.puts "  #{a} -- #{b}" end)
    IO.puts "}"

    # Used graphviz to render to svg:
    # $ dot -Tsvg 25.dot -o 25.svg
    # Visually identified the 3 connections to cut, and commented them
    # Generated the new graph
    # Used browser console: $$('text').filter(t => t.getAttribute("x") < 29000)
    # Nodes to the left: 779
    # Nodes to the right: 778
    product = 778 * 779
    IO.inspect(product, label: "P1")
  end
end

# P1: 606062
