defmodule Day07 do
  @cards ~w(2 3 4 5 6 7 8 9 T J Q K A)
  @cards_low_J ~w(J 2 3 4 5 6 7 8 9 T Q K A)
  @cards_no_J ~w(2 3 4 5 6 7 8 9 T Q K A)

  # Read input as lines
  defp read_input do
    File.read!(Path.expand("../inputs/input07.txt"))
    |> String.split("\n")
    |> Enum.map(fn line ->
      line
      |> String.split(" ")
      |> then(fn [hand, pot] -> {hand, String.to_integer(pot)} end)
    end)
  end

  defp card_value(card, cardlist) do
    Enum.find_index(cardlist, &(&1 == card))
  end

  defp score_hand(orig_hand, hand, cardlist \\ @cards) do
    [a,b,c,d,e] = String.graphemes(orig_hand)

     String.graphemes(hand)
    |> Enum.group_by(fn c -> card_value(c, cardlist) end)
    |> Map.values
    |> Enum.map(fn group ->
      # size of group determines hand rank
      # after that, compare first, second, third, fourth & fifth cards
      # used 20 as card multiplier because 20 > 13
      10000000 * (length(group) ** 2) +
      (160000 * card_value(a, cardlist)) +
      (8000 * card_value(b, cardlist)) +
      (400 * card_value(c, cardlist)) +
      (20 * card_value(d, cardlist)) +
      (card_value(e, cardlist)) end)
    |> Enum.sum
  end

  defp score_hand_with_jokers(hand) do
    if hand =~ "J" do
      @cards_no_J
      |> Enum.map(fn not_J ->
        score_hand(hand, String.replace(hand, "J", not_J), @cards_low_J)
      end)
      |> Enum.max
    else
      score_hand(hand, hand, @cards_low_J)
    end
  end

  defp sort_hands(hands) do
    hands
    |> Enum.map(fn {hand, pot} -> {hand, pot, score_hand(hand, hand)} end)
    |> Enum.sort_by(&(elem(&1, 2)), :desc)
  end

  defp sort_hands_with_jokers(hands) do
    hands
    |> Enum.map(fn {hand, pot} -> {hand, pot, score_hand_with_jokers(hand)} end)
    |> Enum.sort_by(&(elem(&1, 2)), :desc)
  end

  @doc """
  Find total winnings of all scored poker hands
  """
  def part1 do
    read_input()
    |> then(&sort_hands/1)
    |> Enum.reverse
    |> Enum.with_index(1)
    |> Enum.map(fn {{_, pot, _}, i} -> pot * i end)
    |> Enum.sum
    |> IO.inspect(label: "P1")
  end

  @doc """
  Find total winnings of all scored poker hands, when J is a joker
  """
  def part2 do
    read_input()
    |> then(&sort_hands_with_jokers/1)
    |> Enum.reverse
    |> Enum.with_index(1)
    |> Enum.map(fn {{_, pot, _}, i} -> pot * i end)
    |> Enum.sum
    |> IO.inspect(label: "P2")
  end
end

# P1: 249726565
# P2: 251135960
