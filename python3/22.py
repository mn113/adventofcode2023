#! /usr/bin/env python3

class Cube:
    def __init__(self, x, y, z, colour, id):
        self.coords = (x,y,z)
        self.colour = colour
        self.removable = False
        self.brick_id = id

    def __repr__(self):
        return "({},{},{})".format(self.coords[0], self.coords[1], self.coords[2])

    def __eq__(self, other):
        return isinstance(other, Cube) and self.coords == other.coords

    def drop(self):
        self.coords = (self.coords[0], self.coords[1], self.coords[2] - 1)

    def lift(self):
        self.coords = (self.coords[0], self.coords[1], self.coords[2] + 1)

bricks = []

class Brick:
    colours = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

    def __init__(self):
        self.id = len(bricks)
        self.colour = self.colours[self.id % 52]
        self.cubes = []
        self.height = 0
        self.bottom = 999
        self.fixed = False

    def __str__(self):
        return "+".join([str(c) for c in self.cubes])

    def __repr__(self):
        return "Brick__{}".format("+".join([str(c) for c in self.cubes]))

    # Build up the brick
    def add_cube(self, x, y, z):
        cube = Cube(x,y,z, self.colour, self.id)
        self.cubes.append(cube)
        if 0 < self.bottom and z < self.bottom:
            self.bottom = z
        if len(self.cubes) == 1:
            self.height = 1
        elif self.cubes[0].coords[2] != self.cubes[1].coords[2]:
            self.height += 1

    # Move the brick down into position
    def drop(self):
        for c in self.cubes:
            c.drop()
        self.bottom -= 1

    def lift(self):
        for c in self.cubes:
            c.lift()
        self.bottom += 1

    def fix(self):
        global tower
        tower.extend([c for c in self.cubes])
        self.fixed = True

    # brick can be removed if all its cubes can be removed,
    # or for each of its cubes with a brick above it, that brick has another supporter
    def can_be_removed(self):
        #print("CBR?", self.colour)
        # self.removable_cubes = []
        for c in self.cubes:
            #print("cube", c)
            c.removable = False
            if cube_above(c) == None:
                #print("nothing above cube", c)
                c.removable = True
            elif cube_above(c).brick_id == self.id:
                #print("same brick above cube", c)
                c.removable = True
            else:
                brick_above_id = cube_above(c).brick_id
                #print("brick above", bricks[brick_above_id], bricks[brick_above_id].colour)
                supporters = bricks[brick_above_id].get_supporters()
                #print("sup", supporters)
                external_supporters = [c for c in supporters if c.brick_id != self.id]
                #print("ext", external_supporters)
                if len(external_supporters) > 0:
                    #print("multi support for brick", brick_above_id, "above cube", c)
                    c.removable = True


        removable_cubes = [c for c in self.cubes if c.removable]
        #print("removable cubes", removable_cubes)
        if len(self.cubes) == len(removable_cubes):
            print(self.id, self.colour, "IS removable")
        else:
            print(self.id, self.colour, "NOT removable")
        return len(self.cubes) == len(removable_cubes)

    # Get all external cubes supporting this brick
    def get_supporters(self):
        return [cube_below(c) for c in self.cubes if cube_below(c) and cube_below(c).colour != self.colour]


# Check for a cube above another cube
def cube_above(cube):
    above_cubes = [c for c in tower if c.coords == (cube.coords[0], cube.coords[1], cube.coords[2]+1)]
    if len(above_cubes) > 0:
        return above_cubes[0]
    return None

# Check for a cube below another cube
def cube_below(cube):
    below_cubes = [c for c in tower if c.coords == (cube.coords[0], cube.coords[1], cube.coords[2]-1)]
    if len(below_cubes) > 0:
        return below_cubes[0]
    return None


# Parse brick coordinates into bricks
with open('../inputs/input22.txt') as fp:
    linepairs = [line.strip().split("~") for line in fp.readlines()]
    coords = []
    for linepair in linepairs:
        x0, y0, z0 = [int(val) for val in linepair[0].split(",")]
        x1, y1, z1 = [int(val) for val in linepair[1].split(",")]
        coords.append((x0, y0, z0, x1, y1, z1))

    coords.sort(key=lambda tup: tup[2]) # lowest z first

    for (x0, y0, z0, x1, y1, z1) in coords:
        brick = Brick()
        brick.add_cube(x0, y0, z0)
        while x0 != x1:
            x0 += 1
            brick.add_cube(x0, y0, z0)
        while y0 != y1:
            y0 += 1
            brick.add_cube(x0, y0, z0)
        while z0 != z1:
            z0 += 1
            brick.add_cube(x0, y0, z0)
        bricks.append(brick)


# Drop the brick until it rests on a layer
def place_brick(brick):
    while 1:
        intersects = [c for c in brick.cubes if c in tower]
        if len(intersects) > 0:
            brick.lift()
            brick.fix()
            break
        else:
            brick.drop() # all bricks must reach ground level if not stopped
            intersects = [c for c in brick.cubes if c in tower]
            if brick.bottom == 0 and len(intersects) == 0:
                brick.fix()
                break


tower = [Cube(x, y, -1, "-", 0) for y in range(3) for x in range(3)]


# Count the bricks which can be safely disintegrated
def part1():
    for b in bricks[:]:
        place_brick(b)

    # render tower
    top = max([c.coords[2] for c in tower]) + 2
    for z in range(top):
        print(z)
        for y in range(10):
            for x in range(10):
                cubes = [c for c in tower if c.coords == (x,y,z)]
                if len(cubes) >= 1:
                    print(cubes[0].colour, end="")
                else:
                    print(".", end="")
            print("")
        print("")

    return len([b for b in bricks if b.can_be_removed()])


print("Part 1:", part1()) # 411 - very slow
