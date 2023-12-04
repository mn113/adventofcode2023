#!/usr/bin/env ruby

def read_input
    input = File.open("../inputs/input04.txt", "r")
    cards = input.each_line.map do |line|
        /^Card\s+\d+: (?<winners>[\d\s]+) \| (?<my_nums>[\d\s]+)$/ =~ line.chomp
        # matches will be 2 strings of space-separated digits, and double spaces will result in a 0 despite regex split
        winners = winners.chomp.strip.split(/\s+/).map(&:to_i)
        my_nums = my_nums.chomp.strip.split(/\s+/).map(&:to_i)
        [winners, my_nums]
    end
end

def select_my_winners(winners, my_nums)
    winners & my_nums
end

def score_set(my_winners)
    my_winners.size == 0 ? 0 : 2 ** (my_winners.size - 1)
end

##
# Sum scores of all winning cards
def part1
    read_input()
    .map{ |card| select_my_winners(card[0], card[1]) }
    .map{ |s| score_set(s) }
    .reduce(&:+)
end

##
# Gain copies of cards below scoring cards recursively, and count the final amount
def part2
    card_scores = read_input()
    .map{ |card| select_my_winners(card[0], card[1]).size }
    .each_with_index
    .to_a

    to_process = card_scores.dup
    processed = 0
    while to_process.size > 0 do
        card = to_process.shift
        score = card[0]
        index = card[1]
        to_process.concat(card_scores.slice(index + 1, score))
        [card_scores.size, to_process.size]
        processed += 1
    end
    processed
end

p "Part 1: #{part1}" # P1: 20855
p "Part 2: #{part2}" # P2: 5489600
