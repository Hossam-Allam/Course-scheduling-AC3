import json
import itertools
from copy import deepcopy

# --- Step 1: Parse JSON and create lecture variables ---
def parse_courses(json_path):
    with open(json_path) as f:
        course_data = json.load(f)
    
    variables = {}
    for course, count in course_data.items():
        variables[course] = [f"{course}_{i+1}" for i in range(count)]
    
    all_vars = [var for sublist in variables.values() for var in sublist]
    return all_vars, variables

# --- Step 2: Set up domains and neighbors ---
def initialize_domains_and_neighbors(all_vars):
    rooms = list(range(1, 41))  # 40 rooms
    periods = list(range(1, 18))  # 1-17 (4-period lectures)
    base_domain = list(itertools.product(rooms, periods))
    
    domains = {var: deepcopy(base_domain) for var in all_vars}
    neighbors = {var: [v for v in all_vars if v != var] for var in all_vars}
    return domains, neighbors

# --- Step 3: Constraint checking functions ---
def intervals_overlap(p1, p2):
    return not (p1 + 3 < p2 or p2 + 3 < p1)

def consistent(var1, val1, var2, val2):
    room1, period1 = val1
    room2, period2 = val2
    
    # Room conflict check
    if room1 == room2 and intervals_overlap(period1, period2):
        return False
    
    # Same course check
    course1 = var1.split('_')[0]
    course2 = var2.split('_')[0]
    if course1 == course2 and intervals_overlap(period1, period2):
        return False
    
    return True

# --- Step 4: AC-3 Algorithm ---
def revise(domains, xi, xj):
    revised = False
    to_remove = []
    
    for val_i in domains[xi]:
        if not any(consistent(xi, val_i, xj, val_j) for val_j in domains[xj]):
            to_remove.append(val_i)
            revised = True
    
    if to_remove:
        domains[xi] = [v for v in domains[xi] if v not in to_remove]
    
    return revised

def ac3(domains, neighbors):
    queue = [(xi, xj) for xi in domains for xj in neighbors[xi]]
    
    while queue:
        xi, xj = queue.pop(0)
        if revise(domains, xi, xj):
            if not domains[xi]:
                return False
            for xk in neighbors[xi]:
                if xk != xj:
                    queue.append((xk, xi))
    
    return True

# --- Step 5: Backtracking Search with Forward Checking ---
def backtrack(assignment, domains, neighbors):
    if len(assignment) == len(domains):
        return assignment
    
    # Select unassigned variable with smallest domain
    unassigned = [var for var in domains if var not in assignment]
    var = min(unassigned, key=lambda x: len(domains[x]))
    
    for value in domains[var]:
        # Check consistency with current assignment
        conflict = False
        for assigned_var, assigned_val in assignment.items():
            if not consistent(var, value, assigned_var, assigned_val):
                conflict = True
                break
        if conflict:
            continue
        
        # Create copy of domains for forward checking
        new_domains = deepcopy(domains)
        new_assignment = assignment.copy()
        new_assignment[var] = value
        
        # Prune neighbors' domains
        for neighbor in neighbors[var]:
            new_domains[neighbor] = [v for v in new_domains[neighbor] 
                                    if consistent(var, value, neighbor, v)]
            
            if not new_domains[neighbor]:
                break
        else:
            # Recursive call
            result = backtrack(new_assignment, new_domains, neighbors)
            if result is not None:
                return result
    
    return None

# --- Main Execution ---
def main(json_path):
    # Initialize problem
    all_vars, variables = parse_courses(json_path)
    domains, neighbors = initialize_domains_and_neighbors(all_vars)
    
    # Run AC-3 preprocessing
    ac3_success = ac3(domains, neighbors)
    
    if not ac3_success:
        print("No solution exists after AC-3")
        return
    
    # Run backtracking search
    solution = backtrack({}, domains, neighbors)
    
    if solution:
        print("Solution found:")
        for var, (room, period) in solution.items():
            print(f"{var}: Room {room}, Periods {period}-{period+3}")
    else:
        print("No valid schedule exists")

if __name__ == "__main__":
    main("courses.json")