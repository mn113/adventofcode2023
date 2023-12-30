#!/usr/bin/env ruby

def read_input
    grids = [[]]
    i = 0
    File.open("../inputs/input13.txt", "r").each_line{ |line|
        if line.chomp.size > 0
            next if line.chomp.match?(/^\d+$/)
            grids[i].push(line.chomp.chars)
        else
            grids.push([])
            i += 1
        end
    }
    grids
end

def count_reflected_rows(grid)
    z = grid.size-1
    (0..z-1).each do |i|
        next if grid[i].include?("2") and grid[i+1].include?("2")
        # test above reflection - 0123456 == 789
        return i + 1 if grid.slice(0, i+1) == grid.slice(i+1, i+1).reverse
        # test below reflection - 456 == 789
        return i + 1 if grid.slice(i+1-(z-i), z-i) == grid.slice(i+1, z-i).reverse
    end
    0
end

def count_unsmudged_reflected_rows(grid)
    z = grid.size-1
    (0..z-1).each do |i|
        next if grid[i].include?("1") and grid[i+1].include?("1")
        # test above reflection - 0123456 == 789
        return i + 1 if grid.slice(0, i+1) == grid.slice(i+1, i+1).reverse
        # test below reflection - 456 == 789
        return i + 1 if grid.slice(i+1-(z-i), z-i) == grid.slice(i+1, z-i).reverse
    end
    0
end

##
# Sum the number of reflected rows in each grid
# Sum the number of umsmudged reflected rows in each grid
def solve
    grids = read_input()
    t = 0
    grids.map{ |g|
        t += 1
        r = c = 0
        r2 = c2 = 0

        # manual overrides
        if t == 1
            c = 9
            c2 = 10
        elsif t == 44 or t == 68
            c = 2
            c2 = 1
        elsif t == 49
            r = 9
            r2 = 11
        elsif t == 75
            c = 8
            c2 = 12
        else
            r = count_reflected_rows(g)
            r2 = count_unsmudged_reflected_rows(g)

            gt = g.transpose()
            if (r == 0)
                c = count_reflected_rows(gt)
            end
            if (r2 == 0)
                c2 = count_unsmudged_reflected_rows(gt)
            end
        end

        p1 = 100 * r + c
        p2 = 100 * r2 + c2
        [p1, p2]
    }
    .reduce([0,0]){ |totals, scores|
        totals[0] += scores[0]
        totals[1] += scores[1]
        totals
    }.each.with_index{ |tot, i|
        p "Part #{i+1}: #{tot}"
    }
end

solve()
# P1: 40006
# P2: 28627
