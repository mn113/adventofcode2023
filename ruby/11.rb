#!/usr/bin/env ruby

def read_input
    File.open("../inputs/input11.txt", "r").each_line.to_a.map{ |line| line.chomp.chars }
end

def find_row_gaps(grid)
    grid.map.with_index{ |row,i| !row.include?("#") ? [true,i] : [false,i] }
        .filter{ |res| res[0] }
        .map{ |res| res[1] }
end

def find_galaxies(grid)
    galaxies = []
    for y in 0..(grid.size-1) do
        for x in 0..(grid[0].size-1) do
            if grid[y][x] == "#" then galaxies.push([x,y]) end
        end
    end
    galaxies
end

def manhattan_dist(a,b)
    (a[0] - b[0]).abs + (a[1] - b[1]).abs
end

def solve(expansion = 2)
    grid = read_input()
    row_gaps = find_row_gaps(grid)
    col_gaps = find_row_gaps(grid.transpose)
    find_galaxies(grid).combination(2).map{ |pair|
        xs, ys = [pair[0][0], pair[1][0]], [pair[0][1], pair[1][1]]
        md = manhattan_dist(pair[0], pair[1])
        num_row_gaps = row_gaps.filter{ |i| ys.min < i && i < ys.max }.size
        num_col_gaps = col_gaps.filter{ |i| xs.min < i && i < xs.max }.size
        rd = num_row_gaps * (expansion - 1)
        cd = num_col_gaps * (expansion - 1)
        md + rd + cd
    }.reduce(:+)
end

##
# Find the sum of distances between all pairs of galaxies - gaps expanded to 2 units
def part1
    solve()
end

##
# Find the sum of distances between all pairs of galaxies - gaps expanded to 1 million units
def part2
    solve(1_000_000)
end

p "Part 1: #{part1}" # P1: 9918828
p "Part 2: #{part2}" # P2: 692506533832
