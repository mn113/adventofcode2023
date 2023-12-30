require 'set'

# ingest map to 2D array
@grid = File.open("../inputs/input21.txt", "r").each_line.map{ |r| r.chomp.chars }
@ydim = @grid.size
@xdim = @grid[0].size

start_xy = []
start_evenness = 0

# locate START symbol
for y in 0...@ydim do
    for x in 0...@xdim do
        if @grid[y][x] == "S"
            start_xy = [x,y]
            start_evenness = (x + y) % 2
            @grid[y][x] == "."
            break
        end
    end
end

def print_grid(marked)
    for y in (0...@ydim) do
        for x in (0...@xdim) do
            printf (marked.include? [x,y]) ? "O" : @grid[y][x]
        end
        printf "\n"
    end
end

def neighbours(coords)
    x, y = coords
    up    = [x, [y-1, 0].max]
    down  = [x, [y+1, @ydim-1].min]
    left  = [[x-1, 0].max, y]
    right = [[x+1, @xdim-1].min, y]
    [up, down, left, right].reject{ |p| p == coords }
end

def is_hall(coords)
    x, y = coords
    @grid[y][x] == "."
end

# Get Euclidean perimeter points (diamond around center)
#     p
#   p   p
# p   c   p
#   p   p
#     p
def get_perimeter(centre, radius)
    x, y = centre
    x0 = x - radius
    x1 = x + radius
    y0 = y - radius
    y1 = y + radius
    lrun = x0..x # →
    rrun = x..x1 # →
    trun = y0..y # ↓
    brun = y..y1 # ↓
    tl = lrun.zip(trun.to_a.reverse) # /
    bl = lrun.zip(brun) # \
    tr = rrun.zip(trun) # \
    br = rrun.zip(brun.to_a.reverse) # /
    p tl.concat(bl, tr, br).uniq
end

# Take a fixed number of steps in the maze, from start pos
# Which tiles can we visit?
def bfs(start, max_steps)
    dist_to = Hash.new(0)    # measures steps to each node
    visited = Set.new()
    to_visit = [start]

    while to_visit.length > 0 do
        current = to_visit.shift
        visited.add(current)

        if dist_to[current] == max_steps
            # stop this path and choose another
            next
        end

        neighbs = neighbours(current)
            .reject{ |nb| ["#", "/"].include? @grid[nb[1]][nb[0]] }
            .reject{ |nb| visited.include?(nb) }

        neighbs.each do |nextNode|
            # nextNode unseen:
            if !visited.include? nextNode and dist_to[current] + 1 <= max_steps and !to_visit.include? nextNode
                # Add to queue:
                to_visit.push(nextNode)
                # Next node will cost 1 more step than this node did:
                dist_to[nextNode] = dist_to[current] + 1
            end
        end
    end

    # Finished seeing nodes now
    visited.to_a
end

# Part 1 - find number of tiles visitable on the 64th step
max_steps = 64
evens = bfs(start_xy, max_steps).reject{ |p| (p[0] + p[1]) % 2 != start_evenness}
print_grid(evens)
p "Part 1 #{evens.size}"  # 3649

# Part 2 - find number of tiles visitable on the 26501365th step
