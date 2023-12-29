#! /usr/bin/env python3

# Load maze file into nested array:
with open('../inputs/input18.txt') as fp:
    instrs = [[part for part in line_str.strip().split(" ")] for line_str in fp.readlines()]
    # for part 2, decode hex to big integer + direction:
    instrs = [["RDLU"[int(instr[2][7])], int(instr[2][2:7], 16)] for instr in instrs]

EMPTY = "."
DUG = "#"

x0 = 10000
y0 = 10000
x, y = x0, y0
grid2 = {}

dug_corners = []
edge_lengths = {
    'R': 0,
    'L': 0,
    'U': 0,
    'D': 0
}

def dig():
    global x, y
    dug_corners.append((x,y))

dig()

for instr in instrs:
    if instr[0] == 'R':
        edge_lengths['R'] += instr[1]
        x += instr[1]
        dig()
    elif instr[0] == 'L':
        edge_lengths['L'] += instr[1]
        x -= instr[1]
        dig()
    elif instr[0] == 'U':
        edge_lengths['U'] += instr[1]
        y -= instr[1]
        dig()
    elif instr[0] == 'D':
        edge_lengths['D'] += instr[1]
        y += instr[1]
        dig()

# Formula for the area of an irregular rectilinear polygon of many vertices
def shoelace_product(points):
    points.append(points[0])
    fwd_sum = 0
    bkwd_sum = 0
    for i in range(len(points) - 1):
        fwd_sum += points[i][0] * points[i+1][1]
    for i in range(len(points) - 1):
        bkwd_sum += points[i+1][0] * points[i][1]

    return int(abs(fwd_sum - bkwd_sum) / 2)

# Part 2
# Supposing a 5x3 rectangle:
#  +----
#  |oooo
#  |oooo
# The area to measure should be the o's (8) + left or right edge (2) + top or bottom edge (4) + a quarter unit for each + corner
area = shoelace_product(dug_corners) + edge_lengths['L'] + edge_lengths['U'] + 1
print("Part 2:", area) # 127844509405501
