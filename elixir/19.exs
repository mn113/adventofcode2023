defmodule Day19 do

  # Read input and split
  defp read_input do
    File.read!(Path.expand("../inputs/input19.txt"))
    |> String.split("\n\n", trim: true)
    |> Enum.map(&(String.split(&1, "\n", trim: true)))
    |> List.to_tuple
  end

  # Parse a line from the first section of input
  defp parse_instr(str) do
    Regex.named_captures(~r/^(?<id>[a-z]+)\{(?<rules>.+)\}$/, str)
    |> then(fn captures ->
      %{
        :id => captures["id"],
        :rules => captures["rules"] |> String.split(",") |> prune_rules() # pruning done manually in input19b.txt
      }
    end)
  end

  defp prune_rules(["A"]), do: ["A"]
  defp prune_rules(["R"]), do: ["R"]
  defp prune_rules(rules) do
    cond do
      List.last(rules) == "A" and String.ends_with?(Enum.at(rules, -2), "A") ->
        prune_rules(List.delete_at(rules, -2))
      List.last(rules) == "R" and String.ends_with?(Enum.at(rules, -2), "R") ->
        prune_rules(List.delete_at(rules, -2))
      true -> rules
    end
  end

  # Parse a line from the second section of input
  defp parse_part(str) do
    Regex.named_captures(~r/^\{x=(?<x>\d+),m=(?<m>\d+),a=(?<a>\d+),s=(?<s>\d+)\}$/, str)
    |> then(fn captures ->
      %{
        :x => String.to_integer(captures["x"]),
        :m => String.to_integer(captures["m"]),
        :a => String.to_integer(captures["a"]),
        :s => String.to_integer(captures["s"])
      }
    end)
  end

  # Further parse a line from the first section of input
  # returns {rulevar, ruleop, rulenum, decision, redirect}
  defp parse_rule(str) do
    re_gt = ~r/^(?<rulevar>[xmas])>(?<rulenum>\d+):(?<decision>[AR]?)(?<redirect>[a-z]*)$/
    re_lt = ~r/^(?<rulevar>[xmas])<(?<rulenum>\d+):(?<decision>[AR]?)(?<redirect>[a-z]*)$/
    re_id = ~r/^(?<redirect>[a-z]+)$/
    cond do
      str =~ re_gt ->
        Regex.named_captures(re_gt, str)
        |> then(fn m -> {m["rulevar"], :gt, String.to_integer(m["rulenum"]), m["decision"], m["redirect"]} end)
      str =~ re_lt ->
        Regex.named_captures(re_lt, str)
        |> then(fn m -> {m["rulevar"], :lt, String.to_integer(m["rulenum"]), m["decision"], m["redirect"]} end)
      str =~ re_id ->
        Regex.named_captures(re_id, str)
        |> then(fn m -> {nil, nil, nil, nil, m["redirect"]} end)
      str == "A" -> {nil, nil, nil, true, nil} # accept
      str == "R" -> {nil, nil, nil, false, nil} # reject
      true -> raise "oh no!"
    end
  end

  def decide(decision, redirect)
  def decide(true, _), do: :Accept
  def decide(false, _), do: :Reject
  def decide("R", _), do: :Reject
  def decide("A", _), do: :Accept
  def decide(nil, redirect), do: redirect
  def decide("", redirect), do: redirect
  def decide(_, _), do: raise "oaiee!"

  # returns :Accept|:Reject|id|:Next
  defp apply_rule(part, rule) do
    {rulevar, ruleop, rulenum, decision, redirect} = rule
    var = if rulevar, do: String.to_atom(rulevar)
    cond do
      ruleop == :gt -> if part[var] > rulenum, do: decide(decision, redirect), else: :Next
      ruleop == :lt -> if part[var] < rulenum, do: decide(decision, redirect), else: :Next
      true -> decide(decision, redirect)
    end
  end

  # Recursively passes a part through workflows
  defp apply_workflows(part, workflows, id \\ "in", i \\ 0)
  defp apply_workflows(part, workflows, id, i) do
    rule = workflows |> Map.fetch!(id) |> Enum.at(i)
    result = apply_rule(part, rule)
    case result do
      :Accept -> :Accept
      :Reject -> :Reject
      :Next -> apply_workflows(part, workflows, id, i + 1)
      new_id -> apply_workflows(part, workflows, new_id)
    end
  end

  @doc """
  Find sum of accepted part properties
  """
  def part1 do
    workflows = read_input()
    |> elem(0)
    |> Enum.map(&parse_instr/1)
    |> Enum.map(fn %{:id => id, :rules => rules} ->
      { id, Enum.map(rules, &parse_rule/1) }
    end)
    |> Enum.into(%{})

    read_input()
    |> elem(1)
    |> Enum.map(&parse_part/1)
    |> Enum.map(fn part -> {apply_workflows(part, workflows), part} end)
    |> Enum.filter(fn {result, _} -> result == :Accept end)
    |> Enum.map(fn {_, part} -> part
      |> Map.values
      |> Enum.sum
    end)
    |> Enum.sum
    |> IO.inspect(label: "P1")
  end

  # Update a prop 'x|m|a|s' min & max according to a rule
  defp process_part_prop_state(prop_state, rule) do
    %{ min: minimum, max: maximum } = prop_state

    {_, ruleop, rulenum, _, _} = rule

    if ruleop == :gt do # x > 1000 Pass, x <= 1000 Fail
      %{
        :Pass => %{prop_state | :min => rulenum + 1, :max => max(maximum, rulenum + 1)},
        :Fail => %{prop_state | :max => rulenum, :min => min(minimum, rulenum)}
      }
    else if ruleop == :lt # x < 1000 Pass, x >= 1000 Fail
      %{
        :Pass => %{prop_state | :max => rulenum - 1, :min => min(minimum, rulenum - 1)},
        :Fail => %{prop_state | :min => rulenum, :max => max(maximum, rulenum)}
      }
    else # no ruleop -> must be id, :A or :R
      %{
        :Pass => prop_state,
      }
    end
  end

  # Update a part according to the rule of the workflow it's in
  defp process_part_state(part, workflows, id \\ "in", i \\ 0)
  defp process_part_state(part, workflows, id, i) do
    %{ x: x, m: m, a: a, s:s } = part

    rule = workflows |> Map.fetch!(id) |> Enum.at(i)
    {rulevar, ruleop, rulenum, decision, redirect} = rule

    # update the part's x|m|a|s
    if String.contains?("xmas", rulevar) do
      prop_pass_fail_states = process_part_prop_state(part[rulevar], rule)
      %{
        :Pass => %{part | rulevar => prop_pass_fail_states[:Pass]},
        :Fail => %{part | rulevar => prop_pass_fail_states[:Fail]}
      }
    else
      # no ruleop -> passing outcome must be id, :A or :R
      outcome = decide(decision, redirect)
      case outcome do
        :Accept -> %{part | status => :Accept}
        :Reject -> %{part | status => :Reject}
        new_id -> %{part | status => new_id}
      end
      # failling outcome is next id
    end

    # update the part's rule, index and status
    next_status = apply_rule(part)

  end

  # Recursively processes parts queue, returns number of accepted parts
  defp process_parts([], _, accepted), do: accepted
  defp process_parts(parts_queue, workflows, accepted \\ 0) do
    [part0 | rest] = parts_queue
    # update part0's state (x|m|a|s|rule|index)
    part0seen = process_part_state(part0, workflows, part0[:rule], part0[:index])
    cond do
      part0seen[:status] == :Accept ->
        process_parts(rest, workflows, accepted + 1)
      part0seen[:status] == :Reject ->
        process_parts(rest, workflows, accepted)
      true ->
        # append back onto queue for next rule
        process_parts(rest ++ [part0seen], workflows, accepted)
    end
  end

  @doc """
  How many parts would be accepted from all 'xmas' props variant between 0 and 4000
  """
  def part2 do
    workflows = read_input()
    |> elem(0)
    |> Enum.map(&parse_instr/1)
    |> Enum.map(fn %{:id => id, :rules => rules} ->
      { id, Enum.map(rules, &parse_rule/1) }
    end)
    |> Enum.into(%{})

    # thresholds = workflows
    # |> Map.values
    # |> List.flatten
    # |> Enum.reject(&(is_nil(elem(&1, 0))))
    # |> Enum.map(fn {var, op, num, _, _} ->
    #   # need to take a threshold point either side of the < or > operator
    #   if op == :gt,
    #     do: {var, [num, num+1]},
    #     else: {var, [num-1, num]}
    # end)
    # |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
    # # |> IO.inspect(label: "thresholds")

    # [xtups, mtups, atups, stups] = "xmas"
    # |> String.graphemes
    # |> Enum.map(fn g ->
    #   [0] ++ Enum.sort(Enum.uniq(List.flatten(Map.fetch!(thresholds, g)))) ++ [4000]
    #   |> Enum.chunk_every(2, 1, :discard) # take overlapping pairs
    #   |> Enum.map(fn [a, b] -> {a, b - a} end) # start of range, length of range
    # end)

    # [xtups, mtups, atups, stups]
    # |> Enum.map(&length/1)
    # |> IO.inspect(label: "ranges")
    # |> Enum.reduce(1, &Kernel.*/2)
    # |> IO.inspect(label: "total")

    # don't run 1 value in every range (takes too long)
    # TODO: eliminate multiple ranges as soon as a :Reject is returned

    # FIXME: slow...
    # pseudoparts = for x <- xtups, m <- mtups, a <- atups, s <- stups do
    #   %{
    #     :x => elem(x, 0) + 1,
    #     :m => elem(m, 0) + 1,
    #     :a => elem(a, 0) + 1,
    #     :s => elem(s, 0) + 1,
    #     :weight => elem(x, 1) * elem(m, 1) * elem(a, 1) * elem(s, 1),
    #     :at => "in",
    #     :result => nil
    #   }
    # end

    part = %{
      :x => %{ :min => 0, :max => 4000 },
      :m => %{ :min => 0, :max => 4000 },
      :a => %{ :min => 0, :max => 4000 },
      :s => %{ :min => 0, :max => 4000 },
      :rule => "in",
      :index => 0,
      :status => :indeterminate
    }
    # part_states = %{
    #   "in" => part,
    #   :Accept => 0,
    #   :Reject => 0
    # }

    # while parts
    # process part0 at rule
    # increment accepted, set new parts
    # process next rule with remaining parts
    # {new_part_states, accepted, rejected} = part_states
    # |> process_part_state(workflows)

    process_parts([part0], workflows)
    |> IO.inspect

    # IO.inspect {length(pseudoparts), Enum.take(pseudoparts, 3)}


    # pseudoparts
    # |> Enum.map(fn pseudopart ->
    #   out = apply_rule(pseudopart, workflows[pseudopart[:at]])
    #   if out == :Reject || out == :Accept,
    #     do: Map.put(pseudopart, :result, out),
    #     else: Map.put(pseudopart, :at, out)
    # end)
    # |> Enum.reject(&(&1[:result] == :Reject))
    # |> IO.inspect
    # |> Enum.map(&(&1[:weight]))
    # |> Enum.sum
    # |> IO.inspect(label: "P2")
  end
end

# P1: 489392
# P2: runs forever
