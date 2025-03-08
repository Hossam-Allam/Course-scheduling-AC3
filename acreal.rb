require_relative "parse2"

rooms = {
  "A" => 200, "B" => 200, "C" => 40, "D" => 40, "E" => 30, "F" => 30, "G" => 30,
  "H" => 30
}

periods = (1..50).map {|room| room}.to_a
variables = $courses.to_a.first(51).to_h

domains = {}
variables.each_key do |var|
  domains[var] = { rooms: rooms.dup, periods: periods.dup }
end

domains.each do |course, d|
  d[:rooms].select! { |_room, capacity| capacity >= variables[course][:enrollment] }
end

neighbors = {
  "CHEM102_1_1" => ["CHEM122_1_1"],
  "CHEM122_1_1" => ["CHEM102_1_1"]
}

constraints = {
  ["CHEM102_1_1", "CHEM122_1_1"] => lambda {|p1, p2| p1<p2},
  ["CHEM122_1_1", "CHEM102_1_1"] => lambda {|p2, p1| p2>p1}
}


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
  domains[var][:periods].each do |period|
    domains[var][:rooms].each_key do |room|
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