#! /usr/bin/env python3
from itertools import groupby

# Load maze file into nested array:
with open('../inputs/input14.txt') as fp:
    grid = [[char for char in line_str.strip()] for line_str in fp.readlines()]
ydim = len(grid)
xdim = len(grid[0])

def print_grid(label = ""):
    print("\n", label)
    for y in range(ydim):
        for x in range(xdim):
            print(grid[y][x], end="")
        print("")

BALL = "O"
ROCK = "#"
EMPTY = "."

def roll_north():
    # balls go from y+1 to y
    for y in range(ydim-1):
        for x in range(xdim):
            if grid[y][x] == EMPTY and grid[y+1][x] == BALL:
                grid[y][x] = BALL
                grid[y+1][x] = EMPTY

def roll_west():
    # balls go from x+1 to x
    for x in range(xdim-1):
        for y in range(ydim):
            if grid[y][x] == EMPTY and grid[y][x+1] == BALL:
                grid[y][x] = BALL
                grid[y][x+1] = EMPTY

def roll_south():
    # balls go from y-1 to y
    for y in range(ydim-1, 0, -1):
        for x in range(xdim):
            if grid[y][x] == EMPTY and grid[y-1][x] == BALL:
                grid[y][x] = BALL
                grid[y-1][x] = EMPTY

def roll_east():
    # balls go from x-1 to x
    for x in range(xdim-1, 0, -1):
        for y in range(ydim):
            if grid[y][x] == EMPTY and grid[y][x-1] == BALL:
                grid[y][x] = BALL
                grid[y][x-1] = EMPTY

def measure_load():
    load = 0
    multiplier = ydim
    for y in range(ydim):
        for x in range(xdim):
            if grid[y][x] == BALL:
                load += multiplier
        multiplier -= 1
    return load

def snapshot():
    return "\n".join(["".join(row) for row in grid]) # string because unreferenced
    # return rleify(s)

def unsnapshot(snap):
    return [[c for c in line_str.strip()] for line_str in snap.split("\n")]


def part1():
    # roll north until statis
    snap0 = snapshot()
    while 1:
        roll_north()
        snap1 = snapshot()
        if snap1 == snap0:
            break
        snap0 = snap1

    return measure_load()


# load should be measured when t = 10_000_000_000 (or equivalent)
def part2():
    global grid # because assigning back

    t = 0
    goal_t = 1_000_000_000
    period = 1
    snaps = []

    while 1:
        snap1 = snapshot()
        snaps.insert(0, snap1) # build backwards to find period from start

        while 1:
            roll_north()
            snap2 = snapshot()
            if snap2 == snap1:
                if t == 0:
                    print("Part 1: {}".format(measure_load()))
                break
            snap1 = snap2
        while 1:
            roll_west()
            snap2 = snapshot()
            if snap2 == snap1:
                break
            snap1 = snap2
        while 1:
            roll_south()
            snap2 = snapshot()
            if snap2 == snap1:
                break
            snap1 = snap2
        while 1:
            roll_east()
            snap2 = snapshot()
            if snap2 == snap1:
                break
            snap1 = snap2
        t += 1
        print("t =", t, "load:", measure_load())

        if snaps.count(snap2) > 2:
            i = snaps.index(snap2)
            j = snaps.index(snap2, i+1)
            k = snaps.index(snap2, j+1)

            if snaps[i:j] == snaps[j:k]:
                print("Snapshots in reverse range {}-{} match those in {}-{}".format(i,j-1,j,k-1))
                period = j - i
                print("Period", period)
                break

    # [0][ts before repeating section][repeat][repeat][repeat][ts after repeating][goal_t]

    snaps.reverse() # earliest are now first, 0 is initial state
    num_before_first_repeat_snap = snaps.index(snap2)
    print("Before:", num_before_first_repeat_snap)

    remainder_after_repeats = (goal_t - num_before_first_repeat_snap) % period
    print("After:", remainder_after_repeats)

    goal_equivalent_t = num_before_first_repeat_snap + remainder_after_repeats
    print("Time", goal_equivalent_t, "will match", goal_t)

    # reset grid to the state at goal_equivalent_t
    grid = unsnapshot(snaps[goal_equivalent_t])

    print("t =", goal_t, "load:", measure_load())

# part 1 will interfere with part 2 grid - run one only
part2() # 94255
