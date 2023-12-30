#!/usr/bin/env ruby

def read_input
    File.open("../inputs/input12test.txt", "r").each_line.to_a.map{
        |line| line.chomp.split(" ")
    }
end

def form_regex(input)
    middle = input.split(",").map(&:to_i).map{ |n| "#" * n }.join('\.+')
    Regexp.new("^[^#]*" + middle + "[^#]*$")
end

def replace_unknowns(line, knowns)
    while knowns.size > 0 do
        line = line.sub("?", knowns.shift)
    end
    line
end

def solve(lines)
    lines.map{ |line|
        re = form_regex(line[1])
        count_unknowns = line[0].chars.count("?")
        # ? can become . or #
        # permute all variants
        # test each string against pattern
        variants = [".", "#"].repeated_permutation(count_unknowns).to_a
        valids = variants.filter{ |replacements|
            poss_line = replace_unknowns(line[0], replacements)
            poss_line.match?(re)
        }
        valids.size
    }.reduce(:+)
end

##
# Count the variants which fit each line, based on given pattern
def part1
    solve(read_input())
end


# ???.###????.###????.###????.###????.###   1,1,3,1,1,3,1,1,3,1,1,3,1,1,3
# len 39                                    25 filled, 14 gaps
# => 1 arr
#
# ????.#...#...?????.#...#...?????.#...#...?????.#...#...?????.#...#...     4,1,1,4,1,1,4,1,1,4,1,1,4,1,1
# len 69                                                                    30 + 14 chars
# => 2^4 = 16 arrs
#
# ????.######..#####.?????.######..#####.?????.######..#####.?????.######..#####.?????.######..#####.    1,6,5,1,6,5,1,6,5,1,6,5,1,6,5
# #.######.#####.#.######.#####.#.######.#####.#.######.#####.#.######.##### (digits quintupled)
# ___4.######..#####.____5.######..#####.____5.######..#####.____5.######..#####.____5.######..#####
# len 99                                                                                                 60 + 14 chars
# => 4 * 5 * 5 * 5 * 5 = 2500 arrs

##
# Count the variants which fit each line, based on given pattern
# Lines and patterns are quintupled
def part2
    quintuple_input(read_input()).map{ |linepair|
        p ""
        find_combinations(linepair[0], linepair[1].split(",").map(&:to_i))
    }.sum
end

def quintuple_input(lines)
    lines.map do |pair|
        [
            pair[0] + '?' + pair[0] + '?' + pair[0] + '?' + pair[0] + '?' + pair[0],
            pair[1] + ',' + pair[1] + ',' + pair[1] + ',' + pair[1] + ',' + pair[1]
        ]
    end
end

@cache = {}

def trim_start(str)
    str.start_with?(".") ? str.split(/(?<=\.)(?=[^.])/).drop(1).join("") : str
end

# row: "#.##?#.##"
# groups: [1,2,1,2]
def find_combinations(row, groups)
    p [row, groups]

    # const line = row + " " + groups.join(",");
    line = row + " " + groups.join(",")

    # if (@cache[line]) return @cache[line];
    return @cache[line] if @cache[line]

    # if (groups.length <= 0) return Number(!row.includes("#"));
    return (row.include?("#") ? 0 : 1) if groups.length <= 0

    # if (row.length - groups.reduce((a, b) => a + b) - groups.length + 1 < 0) return 0;
    return 0 if row.length - groups.sum - groups.length + 1 < 0

    # const damagedOrUnknown = !row.slice(0, groups[0]).includes(".");
    damagedOrUnknown = !row.slice(0, groups[0]).include?(".")

    # if (row.length == groups[0]) return Number(damagedOrUnknown);
    return (damagedOrUnknown ? 1 : 0) if row.length == groups[0]

    # return @cache[line] ??= (row[0] != "#" ? findCombinations(trimStart(row.slice(1)), groups) : 0) +
    #     (damagedOrUnknown && row[groups[0]] != "#" ? findCombinations(trimStart(row.slice(groups[0] + 1)), groups.slice(1)) : 0);
    return @cache[line] if @cache[line] || @cache[line] == 0
    a = row[0] != "#" ? find_combinations(trim_start(row.slice(1)), groups) : 0
    b = damagedOrUnknown && row[groups[0]] != "#" ? find_combinations(trim_start(row.slice(groups[0] + 1)), groups.drop(1)) : 0
    a + b
end

def compare(pattern, digits, product = 1)
    p pattern
    p numbers = digits.split(",").map(&:to_i)

    length_diff = pattern.length - (numbers.sum + numbers.length - 1)
    return 0 if length_diff < 0
    return 1 if length_diff == 0

    #p pattern2 = numbers.map{ |n| "#" * n }.join("_")

    return product
end

p "Part 1: #{part1}" # P1:
p "Part 2: #{part2}" # P2:
