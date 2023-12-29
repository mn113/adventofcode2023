#! /usr/bin/env python3

# Load maze file into nested array:
with open('../inputs/input18.txt') as fp:
    instrs = [[part for part in line_str.strip().split(" ")] for line_str in fp.readlines()]
    # for part 1, use first 2 parts as direction and length
    instrs = [[instr[0], int(instr[1])] for instr in instrs]

EMPTY = "."
DUG = "#"

xdim = 440
ydim = 620
x0 = 180
y0 = 430
x, y = x0, y0
grid = [[EMPTY for _x in range(xdim)] for _y in range(ydim)] # part 1

def print_grid():
    for y in range(ydim):
        for x in range(xdim):
            print(grid[y][x], end="")
        print("")

dug_points = set([])

def dig():
    global x, y
    grid[y][x] = DUG
    dug_points.add((x,y))

dig()

for instr in instrs:
    if instr[0] == 'R':
        for t in range(instr[1]):
            x += 1
            dig()
    elif instr[0] == 'L':
        for t in range(instr[1]):
            x -= 1
            dig()
    elif instr[0] == 'U':
        for t in range(instr[1]):
            y -= 1
            dig()
    elif instr[0] == 'D':
        for t in range(instr[1]):
            y += 1
            dig()

def grid_val(coords):
    (x,y) = coords
    return grid[y][x]

def neighbours(point):
    (x,y) = point
    up    = (x, y-1)
    down  = (x, y+1)
    left  = (x-1, y)
    right = (x+1, y)
    # nb must not be point (edge/corner cases)
    return [nb for nb in [up, down, left, right] if not (nb[0] == x and nb[1] == y)]

# paint fill algo
def fill_area(start, symbol):
    global x, y
    count = 0
    to_fill = [start]
    while len(to_fill) > 0:
        currentNode, to_fill = to_fill[0], to_fill[1:]
        (x,y) = currentNode
        grid[y][x] = symbol
        count += 1
        tile_neighbours = [nb for nb in neighbours(currentNode) if grid_val(nb) == EMPTY and nb not in to_fill]
        to_fill.extend(tile_neighbours)
    return count

# Part 1
ct = fill_area((x0 - 1, y0 - 1), 'o') # manually pick fill point near start point
# print_grid()
print("Part 1:", len(dug_points) + ct) # 72821
