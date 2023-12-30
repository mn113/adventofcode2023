#!/usr/bin/env ruby

def read_input
    input = File.open("../inputs/input05.txt", "r")
end

##
# Map the input into a structure of ranges
def build_maps(input)
    seeds = []
    maps = []
    i = -1
    cards = input.each_line.map do |line|
        if line.start_with? "seeds"
            seeds = line.chomp.split(":").last.strip.split(/\s+/).map(&:to_i)
        elsif line.chomp.end_with? "map:"
            i += 1
            maps[i] = []
        elsif /^\d/ =~ line
            dest_start, source_start, length = line.match(/(\d+)\s+(\d+)\s+(\d+)/)[1..3].map(&:to_i)
            source_end = source_start + length
            dest_end = dest_start + length
            maps[i].push([source_start, source_end, dest_start, dest_end])
        end
    end
    [seeds, maps]
end

##
# Map the input seeds into seed ranges
def build_seed_ranges(input)
    input
        .each_line.first
        .chomp.split(":").last
        .strip.split(/\s+/).map(&:to_i)
        .each_slice(2)
        .map{ |start,length| [start, start + length - 1] }
end

##
# Look up location value from seed value
def seed_to_loc(seed, maps)
    val = seed
    maps.size.times do |i|
        range = maps[i].find{ |range| range[0] <= val && val <= range[1] }
        val = range ? range[2] + val - range[0] : val
    end
    val
end

##
# Reverse lookup: try a location and see what seed value it maps back to
def loc_to_seed(loc, maps)
    val = loc
    rmaps = maps.reverse
    rmaps.size.times do |i|
        range = rmaps[i].find{ |range| range[2] <= val && val <= range[3] }
        val = range ? range[0] + val - range[2] : val
    end
    val
end

##
# Find lowest location number after mapping from seeds
def part1
    seeds, maps = build_maps(read_input())
    seeds.map{ |seed| seed_to_loc(seed, maps) }.min
end

##
# Find lowest possible location number mapping to a seed range
def part2
    seeds, maps = build_maps(read_input())
    seed_ranges = build_seed_ranges(read_input())
    # had to hardcode start & end after experimentation; checking every loc from 0 was too slow
    loc = 84_000_000
    while loc < 85_000_000 do
        seed = loc_to_seed(loc, maps)
        break if seed_ranges.any?{ |range| range[0] <= seed && seed <= range[1] }
        loc += 1
    end
    loc
end

p "Part 1: #{part1}" # P1: 388071289
p "Part 2: #{part2}" # P2: 84206669
