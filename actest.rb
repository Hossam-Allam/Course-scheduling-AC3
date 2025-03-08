# Available rooms and periods
#rooms   = ["A", "B"]
rooms = { "A" => 50, "B" => 30 }
periods = [1, 2]

# Variables for two courses
#variables = %w[CMPE177_LEC CMPE177_LAB MTE177_LEC MTE177_LAB]
#variables = { "CMPE177_LEC" => 30, "CMPE177_LAB" => 30, "MTE177_LEC" => 50, "MTE177_LAB" => 50 }
#variables = { "CMPE177_LEC" => { enrollment: 30 }, "CMPE177_LAB" => { enrollment: 30 }, "MTE177_LAB" => { enrollment: 50 },
#              "MTE177_LEC" => { enrollment: 50 } }
variables = { "CMPE177_LEC" => { enrollment: 30, professor: "Hossam"}, "CMPE177_LAB" => { enrollment: 30, professor: "Ahmed" }, "MTE177" => { enrollment: 30, professor: "Hossam" } }

# Domain hash separating rooms and periods
domains = {}
variables.each_key do |var|
  domains[var] = { rooms: rooms.dup, periods: periods.dup }
end

# Pre-prune room domains based on course enrollment:
# Only keep rooms that have capacity >= the number of students enrolled in the course.
domains.each do |course, d|
  d[:rooms].select! { |_room, capacity| capacity >= variables[course][:enrollment] }
end

# Variables connected by a constraint
neighbors = {
  "CMPE177_LEC" => ["CMPE177_LAB"],
  "CMPE177_LAB" => ["CMPE177_LEC"]
}

# Hash of arcs as keys and constraints as lambdas
constraints = {
  ["CMPE177_LEC", "CMPE177_LAB"] => lambda { |p_lec, p_lab| p_lec < p_lab },
  ["CMPE177_LAB", "CMPE177_LEC"] => lambda { |p_lab, p_lec| p_lec < p_lab }
}

# AC3 algorithm that only works on the :periods domain (since it's the only constraint yet).
def ac3_periods(domains, neighbors, constraints)
  # our arcs
  queue = constraints.keys.dup

  # iterating through our arcs
  # noinspection RubyControlFlowConversionInspection
  while !queue.empty?
    xi, xj = queue.shift # for every value of xi there must be a suitable value in xj
    if revise_period(xi, xj, domains, constraints[[xi, xj]])
      # No values remained (impossible problem)
      return false if domains[xi][:periods].empty?
      # For each neighbor of xi (except xj), add the arc (xk, xi) back into the queue.
      neighbors[xi].each do |xk|
        queue << [xk, xi] if xk != xj
      end
    end
  end
  domains
end

# Revise the :periods domain of xi given the constraint with xj.
def revise_period(xi, xj, domains, constraint)
  revised = false
  # Iterate over a copy of xi's period domain.
  domains[xi][:periods].dup.each do |p|
    # Remove p if no period in xj's domain is consistent.
    unless domains[xj][:periods].any? { |q| constraint.call(p, q) }
      domains[xi][:periods].delete(p)
      revised = true
    end
  end
  revised
end

ac3_result = ac3_periods(domains, neighbors, constraints)
unless ac3_result
  puts "AC3 failed to find a consistent assignment."
  exit
end

# backtracking portion

# The backtracking algorithm will try to assign each course a room and period.
def backtrack(assignment, course_data, domains, constraints)
  # If all courses have been assigned, return the assignment.
  return assignment if assignment.keys.sort == course_data.keys.sort

  # Select an unassigned course (variable)
  var = course_data.keys.find { |v| !assignment.key?(v) }

  # For the chosen course, iterate over all possible values.
  # The values are the Cartesian product of the pruned room and period domains.
  domains[var][:rooms].each_key do |room|
    domains[var][:periods].each do |period|
      value = { room: room, period: period }
      # Check if assigning this value to var is consistent with already made assignments.
      if consistent?(assignment, var, value, constraints, course_data)
        # Add the assignment for var.
        assignment[var] = value
        # Recursively attempt to complete the assignment.
        result = backtrack(assignment, course_data, domains, constraints)
        return result if result
        # If no solution found, remove the assignment (backtrack).
        assignment.delete(var)
      end
    end
  end

  # No valid assignment found for this branch.
  nil
end

# Consistency check: Ensure that assigning the given value to var doesn't violate constraints.
def consistent?(assignment, var, value, constraints, course_data)
  assignment.each do |course, course_value|
    # Check binary constraints (e.g., lecture-lab ordering, professor conflict) if they exist.
    if constraints.key?([var, course])
      unless constraints[[var, course]].call(value[:period], course_value[:period])
        return false
      end
    end
    if constraints.key?([course, var])
      unless constraints[[course, var]].call(course_value[:period], value[:period])
        return false
      end
    end

    # Check for room conflict: a room cannot be used by two different courses at the same period.
    if course_value[:room] == value[:room] && course_value[:period] == value[:period]
      return false
    end

    if course_data[course][:professor] == course_data[var][:professor] && course_value[:period] == value[:period]
      return false
    end
  end
  true
end



# Run the backtracking search on the pruned domains.
solution = backtrack({}, variables, domains, constraints)

if solution
  puts "Backtracking succeeded. Final assignments:"
  solution.each do |course, value|
    puts "#{course}: Room #{value[:room]}, Period #{value[:period]}"
  end
else
  puts "No valid assignment found."
end