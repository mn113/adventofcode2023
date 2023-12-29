def read_input():
    with open('../inputs/input08.txt') as fp:
        lines = fp.readlines()
        instructions = lines[0].strip()
        relations = [line.strip().split(" = ") for line in lines[2:]]
        relations = [[rel[0], rel[1].replace('(', '').replace(')', '').split(', ')] for rel in relations]
        relations = dict(relations)
        return (instructions, relations)

# Find the number of steps from start to end
def run_path_search(instructions, relations, start, end):
    thisval = start
    i = 0
    while True:
        instruction_LR = instructions[i % len(instructions)]
        instruction_01 = { 'L': 0, 'R': 1}[instruction_LR]
        thisval = relations[thisval][instruction_01]
        i = i + 1
        if thisval == end:
            break
    return i

# AI-generated
def gcd(a, b):
    while b:
        a, b = b, a % b
    return a

# AI-generated
def lcm(a, b):
    return a * b // gcd(a, b)

# Find the number of steps from AAA to ZZZ
def part1():
    (instructions, relations) = read_input()
    return run_path_search(instructions, relations, 'AAA', 'ZZZ')

# Find the number of steps for all traversers to simultaneously get from **A to **Z
def part2():
    (instructions, relations) = read_input()
    startvals = [val for val in relations.keys() if val.endswith('A')]
    endvals = [val for val in relations.keys() if val.endswith('Z')]
    # should the 6 startvals map 1:1 to the 6 endvals? YES
    t = run_path_search(instructions, relations, 'AAA', 'ZZZ')
    u = run_path_search(instructions, relations, 'NVA', 'HVZ')
    v = run_path_search(instructions, relations, 'GQA', 'TKZ')
    w = run_path_search(instructions, relations, 'XCA', 'LLZ')
    x = run_path_search(instructions, relations, 'HBA', 'JLZ')
    y = run_path_search(instructions, relations, 'GVA', 'KJZ')

    return lcm(t, lcm(u, lcm(v, lcm(w, lcm(x, y)))))

print('p1', part1()) # 18727
print('p2', part2()) # 18024643846273
