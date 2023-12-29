def read_input():
    with open('../inputs/input09.txt') as fp:
        lines = fp.readlines()
        return [[int(val) for val in line.strip().split(' ')] for line in lines]

def get_diffs(row):
    if len(row) < 3:
        return [0]
    return [b - a for a, b in zip(row, row[1:])]

def build_subrows(toprow):
    subrows = [toprow]
    while len(subrows[-1]) > 1 and set(subrows[-1]) != set([0]):
        subrows.append(get_diffs(subrows[-1]))
    return subrows

def extrapolate_next(subrows):
    # start at the row of zeroes
    y = len(subrows) - 1
    while y > 0:
        subrows[y-1].append(subrows[y-1][-1] + subrows[y][-1])
        y -= 1
    return subrows[0][-1]

def extrapolate_prev(subrows):
    # start at the row of zeroes
    y = len(subrows) - 1
    while y > 0:
        subrows[y-1].insert(0, subrows[y-1][0] - subrows[y][0])
        y -= 1
    return subrows[0][0]

# Find the sum of predicted next values for each sequence
def part1():
    total = 0
    rows = read_input()
    for row in rows:
        subrows = build_subrows(row)
        total += extrapolate_next(subrows)
    return total

# Find the sum of predicted previous values for each sequence
def part2():
    total = 0
    rows = read_input()
    for row in rows:
        subrows = build_subrows(row)
        total += extrapolate_prev(subrows)
    return total

print('p1', part1()) # 1974232246
print('p2', part2()) # 928
