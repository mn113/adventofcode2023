require 'pp'

# ingest map to 2D array
@grid = File.open("../inputs/input23.txt", "r").each_line.map{ |r| r.chomp.chars }
@ydim = @grid.size
@xdim = @grid[0].size

def print_grid(marked = [])
    for y in (0...@ydim) do
        for x in (0...@xdim) do
            printf (marked.include? [x,y]) ? "O" : @grid[y][x]
        end
        printf "\n"
    end
end

def neighbours(coords, count_slopes = true)
    x, y = coords
    up    = [x, [y-1, 0].max]
    down  = [x, [y+1, @ydim-1].min]
    left  = [[x-1, 0].max, y]
    right = [[x+1, @xdim-1].min, y]
    if count_slopes
        # reject uphills
        up = grid_val(up) == "v" ? false : up
        down = grid_val(down) == "^" ? false : down
        left = grid_val(left) == ">" ? false : left
        right = grid_val(right) == "<" ? false : right
    end
    [up, down, left, right].reject{ |t| t == false or t == coords or is_wall(t) }
end

def grid_val(coords)
    x, y = coords
    @grid[y][x]
end

def is_wall(coords)
    grid_val(coords) == "#"
end

def longest_path(start, goal, count_slopes)
    open_paths = [[start]]
    completed_paths = []
    dead_paths = []
    excessive_paths = []
    longest = 0

    while open_paths.size > 0 do
        current_path = open_paths.shift
        # condition to limit Part 2 run time
        if current_path.size > 5000
            excessive_paths.push(current_path)
            next
        end

        current = current_path[-1]

        while true do
            valid_neighbs = neighbours(current, count_slopes).reject{ |t| current_path.include?(t) }

            if valid_neighbs.size == 0 # dead end?
                if current == goal
                    p "Goal, steps #{current_path.size}"
                    completed_paths.push(current_path)
                    longest = current_path.size if current_path.size > longest
                else
                    dead_paths.push(current_path)
                end
                break
            elsif valid_neighbs.size == 1 # corridor - stay in this loop
                current = valid_neighbs[0]
                current_path.push(current)
                next
            else # inflection point - split off new path for each nb
                open_paths.concat(valid_neighbs.map{ |nb| current_path.dup.push(nb) })
                break
            end
        end
        p "#{open_paths.size} open, #{completed_paths.size} completed, #{dead_paths.size} dead, #{excessive_paths.size} excessive, longest #{longest}"
    end

    # Finished all paths now
    p "Finished pathfinding"
    longest = completed_paths.sort{ |p1,p2| p2.size - p1.size }.first
    print_grid(longest)
    longest.size
end

start_xy = [1, 1]
goal_xy = [@xdim-2, @ydim-1]

# Part 1 - find longest path. Cannot travel up slopes
#lp1 = longest_path(start_xy, goal_xy, true)
#p "Part 1: #{lp1}" # 2170

# Part 2 - slopes (^V<>) don't matter
# Needs to be solved as a DAG:
# Collect all dot tiles with 3 or 4 neighbours
# Measure distances between each pair of connected nodes
# Run a BFS over this weighted DAG
@nodes = [start_xy, goal_xy]
for y in (0...@ydim) do
    for x in (0...@xdim) do
        next if is_wall([x,y])
        n = neighbours([x,y], false)
        if n.size > 2
            @nodes.push([x,y])
        end
    end
end
p "#{@nodes.size} nodes"

# keys: [x,y] values: { [x,y]: N }
@distances = {}


# Walk all the inter-node simple corridors, storing the distances
def walk_paths_from_node(start)
    node_paths = neighbours(start, false).map{ |nb| [start, nb] }
    until node_paths.uniq == [nil] do
        node_paths.map!{ |npath|
            if npath.nil?
                nil
            else
                head = npath.last
                if @nodes.include?(head)
                    @distances[start] = @distances[start] || {}
                    @distances[start][head] = npath.size - 1
                    nil
                else
                    nbs = neighbours(head, false).reject{ |t| npath.include?(t) }
                    if nbs.size == 1 # expected
                        npath.push(nbs[0])
                    end
                    npath
                end
            end
        }
    end
end

@nodes.each{ |node|
    walk_paths_from_node(node)
}
pp @distances

def longest_dag_path(start, goal)
    open_paths = [{path: [start], score: 0}]
    completed_paths = []
    dead_paths = []
    longest = 0

    while open_paths.size > 0 do
        current_path = open_paths.shift

        current_node = current_path[:path][-1]

        while true do
            valid_neighbs = @distances[current_node].keys.reject{ |t| current_path[:path].include?(t) }

            if valid_neighbs.size == 0 # dead end?
                if current_node == goal
                    p "Goal, steps #{current_path[:score]}, route #{current_path[:path]}"
                    completed_paths.push(current_path)
                    longest = current_path[:score] if current_path[:score] > longest
                else
                    dead_paths.push(current_path)
                end
                break
            else # inflection point - split off new path for each nb
                open_paths.concat(valid_neighbs.map{ |nb|
                    {
                        path: current_path[:path].dup.push(nb),
                        score: current_path[:score] + @distances[current_node][nb]
                    }
                })
                break
            end
        end
        p "#{open_paths.size} open, #{completed_paths.size} completed, #{dead_paths.size} dead, longest #{longest + 1}"
    end

    p "Finished pathfinding"
    longest
end

p longest_dag_path(start_xy, goal_xy) # 6502 - completes in 23 minutes
