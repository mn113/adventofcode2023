#! /usr/bin/env python3

# Load grid into nested array:
with open('../inputs/input16.txt') as fp:
    grid = [[char for char in line_str.strip()] for line_str in fp.readlines()]
ydim = len(grid)
xdim = len(grid[0])

def print_grid(label = ""):
    print("\n", label)
    for y in range(ydim):
        for x in range(xdim):
            print(grid[y][x], end="")
        print("")


def aim_north(photon):
    photon.update({ "dx": 0, "dy": -1 })

def aim_south(photon):
    photon.update({ "dx": 0, "dy": 1 })

def aim_west(photon):
    photon.update({ "dx": -1, "dy": 0 })

def aim_east(photon):
    photon.update({ "dx": 1, "dy": 0 })


cache = {}

def cache_photon_result(photon, val):
    # global cache
    # tuple is hashable, dict not
    key = (photon["x"], photon["y"], photon["dx"], photon["dy"])
    cache[key] = val

def lookup_photon_result(photon):
    key = (photon["x"], photon["y"], photon["dx"], photon["dy"])
    if key in cache.keys():
        return cache[key]
    return None


def update_photon(photon):
    # don't log starting photon if out of bounds
    if photon["x"] >= 0 and photon["x"] < xdim and photon["y"] >= 0 and photon["y"] < ydim:
        update_energized(photon)

    # optimisation:
    cached_photon_result = lookup_photon_result(photon)
    if cached_photon_result:
        return [] # exits too early
        return cached_photon_result # loops many times

    x1, y1 = photon["x"] + photon["dx"], photon["y"] + photon["dy"]
    # discard if going out of bounds
    if x1 < 0 or x1 >= xdim or y1 < 0 or y1 >= ydim:
        return []

    ahead = grid[y1][x1]

    is_empty = ahead == "."
    # - and | tubes let photon pass through
    is_tube_h = ahead == "-" and photon["dy"] == 0
    is_tube_v = ahead == "|" and photon["dx"] == 0
    # _ and | walls split photon into 2 and emitted at 90 degrees
    is_wall_v = ahead == "-" and photon["dx"] == 0
    is_wall_h = ahead == "|" and photon["dy"] == 0
    # \ and / mirrors reflect photon 90 degrees
    is_mirror_cw_q1 = ahead == "\\" and photon["dy"] == 1
    is_mirror_cw_q2 = ahead == "/" and photon["dx"] == -1
    is_mirror_cw_q3 = ahead == "\\" and photon["dy"] == -1
    is_mirror_cw_q4 = ahead == "/" and photon["dx"] == 1
    is_mirror_ccw_q4 = ahead == "/" and photon["dy"] == 1
    is_mirror_ccw_q3 = ahead == "\\" and photon["dx"] == 1
    is_mirror_ccw_q2 = ahead == "/" and photon["dy"] == -1
    is_mirror_ccw_q1 = ahead == "\\" and photon["dx"] == -1

    # prep the new photon, advanced 1 tile
    p1 = photon.copy()
    p1.update({ "x": x1, "y": y1 })

    if is_empty or is_tube_h or is_tube_v:
        # continues moving through
        cache_photon_result(photon, [p1])
        return update_photon(p1)

    elif is_wall_v:
        # wall creates 2 photons
        p2 = p1.copy()
        aim_east(p1)
        aim_west(p2)
        cache_photon_result(photon, [p1, p2])
        return [p1, p2]

    elif is_wall_h:
        # wall creates 2 photons
        p2 = p1.copy()
        aim_north(p1)
        aim_south(p2)
        cache_photon_result(photon, [p1, p2])
        return [p1, p2]

    else:
        if is_mirror_cw_q1 or is_mirror_ccw_q2:
            # enters south, reflects east
            aim_east(p1)

        elif is_mirror_cw_q2 or is_mirror_ccw_q3:
            # enters east, reflects south
            aim_south(p1)

        elif is_mirror_cw_q3 or is_mirror_ccw_q4:
            # enters north, reflects west
            aim_west(p1)

        elif is_mirror_cw_q4 or is_mirror_ccw_q1:
            # enters west, reflects north
            aim_north(p1)

        elif is_mirror_ccw_q4:
            # enters south, reflects west
            # photon["x"] = x1
            # photon["y"] = y1
            # photon["dx"] = -1
            # photon["dy"] = 0
            p1.update({ "dx": -1, "dy": 0 })

        elif is_mirror_ccw_q3:
            # enters west, reflects south
            # photon["x"] = x1
            # photon["y"] = y1
            # photon["dx"] = 0
            # photon["dy"] = 1
            p1.update({ "dx": 0, "dy": 1 })

        elif is_mirror_ccw_q2:
            # enters north, reflects east
            # photon["x"] = x1
            # photon["y"] = y1
            # photon["dx"] = 1
            # photon["dy"] = 0
            p1.update({ "dx": 1, "dy": 0 })

        elif is_mirror_ccw_q1:
            # enters west, reflects north
            # photon["x"] = x1
            # photon["y"] = y1
            # photon["dx"] = 0
            # photon["dy"] = -1
            p1.update({ "dx": 0, "dy": -1 })

        cache_photon_result(photon, [p1])
        return [p1]


energized = set([])


def update_energized(photon):
    coord = (photon["x"], photon["y"])
    energized.add(coord)


def light_up_grid(photons):
    global cache, energized
    # reset cache & tile count
    cache = {}
    energized = set([])

    while len(photons) > 0:
        photon, photons = photons[0], photons[1:]
        photons.extend(update_photon(photon))

    return len(energized)


# Count the energized tiles after passing all light beams
def part1():
    photons = [{ "x": -1, "y": 0, "dx": 1, "dy": 0 }] # starting photon
    return light_up_grid(photons)


# Find the light entry point for maximal energization
def part2():
    max = 0

    # beam light into all y rows
    for y in range(ydim):
        # from the left
        res = light_up_grid([{ "x": -1, "y": y, "dx": 1, "dy": 0 }])
        if res > max:
            max = res

    for y in range(ydim):
        # from the right
        res = light_up_grid([{ "x": xdim, "y": y, "dx": -1, "dy": 0 }])
        if res > max:
            max = res

    # beam light into all x cols
    for x in range(xdim):
        # from the top
        res = light_up_grid([{ "x": x, "y": -1, "dx": 0, "dy": 1 }])
        if res > max:
            max = res

    for x in range(xdim):
        # from the bottom
        res = light_up_grid([{ "x": x, "y": ydim, "dx": 0, "dy": -1 }])
        if res > max:
            max = res

    return max

print("Part 1:", part1()) # 8098
print("Part 2:", part2()) # 8335
