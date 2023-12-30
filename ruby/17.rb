require 'pp'
require 'set'

# ingest map to 2D array
@grid = File.open("../inputs/input17.txt", "r").each_line.map{ |r| r.chomp.chars.map(&:to_i) }
@ydim = @grid.size
@xdim = @grid[0].size

@allowed_dirs = {
    "U" => ["R", "L"],
    "D" => ["R", "L"],
    "L" => ["U", "D"],
    "R" => ["U", "D"],
    "-" => ["R", "D"]
}

# Get neighbours based on max 3 steps and an enforced turn
def neighbours(coords, dir)
    x, y = coords
    up1    = [x, [y-1, 0].max, "U"]
    up2    = [x, [y-2, 0].max, "U"]
    up3    = [x, [y-3, 0].max, "U"]
    down1  = [x, [y+1, @ydim-1].min, "D"]
    down2  = [x, [y+2, @ydim-1].min, "D"]
    down3  = [x, [y+3, @ydim-1].min, "D"]
    left1  = [[x-1, 0].max, y, "L"]
    left2  = [[x-2, 0].max, y, "L"]
    left3  = [[x-3, 0].max, y, "L"]
    right1 = [[x+1, @xdim-1].min, y, "R"]
    right2 = [[x+2, @xdim-1].min, y, "R"]
    right3 = [[x+3, @xdim-1].min, y, "R"]
    [up1, up2, up3, down1, down2, down3, left1, left2, left3, right1, right2, right3].uniq
        .select{ |nb| @allowed_dirs[dir].include?(nb[2]) }
        .reject{ |nb| nb.slice(0,2) == [x,y] }
end

# Route cannot exceed 3 steps in a straight line
def not_too_straight(latest, came_from)
    prev1 = came_from[latest]
    prev2 = came_from[prev1]
    return true if !prev2
    prev3 = came_from[prev2]
    return true if !prev3
    prev4 = came_from[prev3]
    return true if !prev4

    # good if deltas are not all equal
    pairs = [latest, prev1, prev2, prev3, prev4].each_cons(2).to_a
    deltas = pairs.map{ |a,b| [ b[0]-a[0], b[1]-a[1] ] }
    straight = deltas.uniq.size == 1
    if straight
        p ">> STRAIGHT! #{[latest, prev1, prev2, prev3, prev4]}"
    end
    !straight
end

# Get grid cost of moving along a straight sequence of tiles
def grid_cost(from, to)
    x0, y0 = from
    x1, y1 = to
    cost = 0
    while [x0,y0] != [x1,y1] do
        x0 += (x0 < x1 ? 1 : x0 > x1 ? -1 : 0)
        y0 += (y0 < y1 ? 1 : y0 > y1 ? -1 : 0)
        cost += @grid[y0][x0]
    end
    cost
end

# Main algo:
def bfs(start, goal)
    visited = Set.new()
    cost_to = Hash.new(0)  # measures cost of steps to each node
    came_from = {}  # traces the optimal path taken (without dir)
    lowest_cost_to_goal = 999999
    initial_state = [start[0], start[1], "-"]
    to_visit = [initial_state]

    while to_visit.length > 0 do
        # make it a priority queue
        to_visit.sort!{ |s1,s2| cost_to[s1] - cost_to[s2] }

        current_state = to_visit.shift
        visited.add(current_state)
        p "@ #{current_state}, costing #{cost_to[current_state]}"

        current_node = current_state.slice(0,2)
        current_dir = current_state[2]

        if current_node == goal
            p "Goal, cost #{cost_to[current_state]}"
            if cost_to[current_state] < lowest_cost_to_goal
                lowest_cost_to_goal = cost_to[current_state]
            end
            next
        end

        neighbs = neighbours(current_node, current_dir)

        neighbs.each do |next_state|
            next_node = next_state.slice(0,2)
            next_dir = next_state[2]
            #p "evaluating nb #{next_node} #{next_dir}"

            # Calculate cost of next_node based on current_state:
            step_cost = grid_cost(current_node, next_node)
            new_cost_to_next = cost_to[current_state] + step_cost
            if new_cost_to_next > lowest_cost_to_goal
                next
            end

            # next_node unseen:
            if !visited.include?(next_state)
                p "will visit new node #{next_node} #{next_dir}, will cost #{cost_to[current_state]} + #{step_cost}"
                cost_to[next_state] = new_cost_to_next
                came_from[next_state] = current_state
                # Add unseen state to queue:
                if !to_visit.include?(next_state)
                   to_visit.push(next_state)
                end
            # next_node seen before:
            else
                if new_cost_to_next < cost_to[next_state]
                    # Via current_state, we have found a new, cheaper path to this known next_node:
                    p "will revisit node #{next_node} #{next_dir} cheaper, will cost #{cost_to[current_state]} + #{step_cost}"
                    cost_to[next_state] = new_cost_to_next
                    came_from[next_state] = current_state
                end
            end
        end
    end


    # Finished seeing nodes now
    p "DONE, lowest cost #{lowest_cost_to_goal}"
    #pp came_from
    if came_from.keys.any?{ |state| state.slice(0,2) == goal }
        #p cost_to
        traceback(goal, came_from)
    else
        p "No path found"
    end
end

# Traceback function:
def traceback(goal, came_from)
    node = [goal[0], goal[1], "R"]
    route = [node]
    p "Traceback from goal #{node}"
    until node.nil? do
        node = came_from[node]
        route.push(node) if !node.nil?
        #p route
    end
    p route
    for y in (0...@ydim) do
        for x in (0...@xdim) do
            printf (route.map{ |n| n.slice(0,2) }.include? [x,y]) ? "R" : "."
        end
        printf "\n"
    end
end

bfs([0, 0], [@xdim-1, @ydim-1])
