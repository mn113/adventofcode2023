#!/usr/bin/env ruby

def read_input
    File.open("../inputs/input06.txt", "r").each_line.to_a.map(&:chomp)
end

def read_4_ints(str)
    str.match(/(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/)[1..4].map(&:to_i)
end

def read_1_int(str)
    str.gsub(/\s+/, '').match(/(\d+)/)[1].to_i
end

def read_input1
    timestr, diststr = read_input()
    times = read_4_ints(timestr)
    dists = read_4_ints(diststr)
    times.zip(dists)
end

def read_input2
    timestr, diststr = read_input()
    time = read_1_int(timestr)
    dist = read_1_int(diststr)
    [time, dist]
end

##
# Convert input_time to initial speed, return distance run over remaining race_time
def run_race(input_time, race_time)
    v0 = input_time
    v0 * (race_time - input_time)
end

##
# Find race distances for a range of input times
def map_times_to_distances(max_race_time)
    (1..max_race_time-1).map{ |t| [t, run_race(t, max_race_time)] }
end

##
# Count the results which beat the record_dist
def count_winners(results, record_dist)
    results.select{ |pr| pr[1] > record_dist }.length
end

##
# Find the point at which the time t generates distance greater than record_dist
def binary_search_first_winning_input(race_time, record_dist)
    (1..race_time-1).bsearch{ |t| run_race(t, race_time) > record_dist }
end

##
# Find the product of numbers of ways to beat each race record
def part1
    read_input1()
    .map{ |pair| count_winners(map_times_to_distances(pair[0]), pair[1]) }
    .reduce(&:*)
end

##
# Find number of ways to beat the race record (different input parsing)
def part2
    t, d = read_input2()
    tmin = binary_search_first_winning_input(t, d)
    t - tmin - tmin + 1
end

p "Part 1: #{part1}" # P1: 840336
p "Part 2: #{part2}" # P2: 41382569
