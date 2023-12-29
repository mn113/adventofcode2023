#! /usr/bin/env python3

# Load maze file into nested array:
with open('../inputs/input10.txt') as fp:
    grid = [[char for char in line_str.strip()] for line_str in fp.readlines()]
ydim = len(grid)
xdim = len(grid[0])
print("total tiles", xdim * ydim)

def print_grid():
    for y in range(ydim):
        for x in range(xdim):
            print(grid[y][x], end="")
        print("")

START_CHAR = "S"
CAN_ENTER_UP = CAN_EXIT_DOWN = ["|", "F", "7", START_CHAR]
CAN_ENTER_DOWN = CAN_EXIT_UP = ["|", "L", "J", START_CHAR]
CAN_ENTER_RIGHT = CAN_EXIT_LEFT = ["-", "7", "J", START_CHAR]
CAN_ENTER_LEFT = CAN_EXIT_RIGHT = ["-", "F", "L", START_CHAR]

start_xy = None

# need to locate START symbol
for y in range(ydim):
    for x in range(xdim):
        if grid[y][x] == START_CHAR:
            start_xy = (x,y)
            break

def grid_val(coords):
    (x,y) = coords
    return grid[y][x]

def neighbours(point):
    (x,y) = point
    up    = (x, max(y-1, 0))
    down  = (x, min(y+1, ydim-1))
    left  = (max(x-1, 0), y)
    right = (min(x+1, xdim-1), y)
    # nb must not be point (edge/corner cases)
    return [nb for nb in [up, down, left, right] if not (nb[0] == x and nb[1] == y)]

# Return valid points of [down, left, up, right] from given point (x,y)
def connected_neighbours(point):
    nbs = []
    pointval = grid_val(point)
    (x,y) = point
    up    = (x, max(y-1, 0))
    down  = (x, min(y+1, ydim-1))
    left  = (max(x-1, 0), y)
    right = (min(x+1, xdim-1), y)

    # disqualify disconnected
    if pointval in CAN_EXIT_UP and grid_val(up) in CAN_ENTER_UP:
        nbs.append(up)
    if pointval in CAN_EXIT_DOWN and grid_val(down) in CAN_ENTER_DOWN:
        nbs.append(down)
    if pointval in CAN_EXIT_RIGHT and grid_val(right) in CAN_ENTER_RIGHT:
        nbs.append(right)
    if pointval in CAN_EXIT_LEFT and grid_val(left) in CAN_ENTER_LEFT:
        nbs.append(left)

    # print(point, nbs)
    # nb must not be point (edge/corner cases)
    return [nb for nb in nbs if not (nb[0] == x and nb[1] == y)]

dots = []

# Main algo: Dijkstra / BFS
# Finds lowest cost path from start to goal. Visits all points in grid, storing and updating cost to reach each one.
def dijkstra(start, goal):
    steps_to = {start: 0} # measures cumulative cost from start to each node; keys function as "seen" list
    to_visit = [start]          # list-as-queue
    came_from = {start: None}   # traces the optimal path taken

    while len(to_visit) > 0:
        # Shift first
        currentNode, to_visit = to_visit[0], to_visit[1:]
        # currentVal = grid_val(currentNode)
        # print(currentNode, currentVal, steps_to[currentNode])

        # if currentNode == goal and steps_to[currentNode] > 0:
        #     print('GOAL!', len(to_visit), "to see")
        #     # Keep searching, to guarantee shortest:
        #     continue

        neighbs = connected_neighbours(currentNode)

        for nextNode in neighbs:
            # nextNode unseen:
            if nextNode not in steps_to.keys():
                to_visit.append(nextNode)
                # Next node will cost 1 more than this node did:
                steps_to[nextNode] = steps_to[currentNode] + 1
                came_from[nextNode] = currentNode

    if goal in came_from.keys():
        print("tiles in loop?", len(came_from.keys()))
        print("p1: steps to furthest point:", max(steps_to.values()))
        # fill untouched points
        for y in range(ydim):
            for x in range(xdim):
                if (x,y) not in steps_to.keys():
                    grid[y][x] = "x"
                    dots.append((x,y))
        # print_grid()
        print("dots:", len(dots))


# part 1 - find furthest connected point from start
dijkstra(start_xy, start_xy) # P1: 6823

def extend_grid(g):
    wider_grid = []
    for row in g:
        wider_grid.append(["."] + row + ["."])
    taller_grid = []
    taller_grid.extend([["."] * (xdim + 2)])
    taller_grid.extend(wider_grid)
    taller_grid.extend([["."] * (xdim + 2)])
    return taller_grid

# part 2 - count tiles enclosed by the part 1 loop
grid = extend_grid(grid)
ydim = len(grid)
xdim = len(grid[0])

# paint fill algo
def fill_dots_area(start, symbol):
    global dots
    to_fill = [start]
    while len(to_fill) > 0:
        currentNode, to_fill = to_fill[0], to_fill[1:]
        (x,y) = currentNode
        grid[y][x] = symbol
        dots = [d for d in dots if d != currentNode]
        dot_neighbours = [nb for nb in neighbours(currentNode) if grid_val(nb) == "." and nb not in to_fill]
        to_fill.extend(dot_neighbours)

fill_dots_area((0,0), "O")
fill_dots_area((70,70), "I")

print_grid() # -> day10-part2-grid.txt : from here, solved using vscode.dev -> edit styles -> screenshot -> online fill tool -> print -> count inner dots by hand
