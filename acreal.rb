require_relative "parse2"

rooms = {"LAB1" => 20, "LAB2" => 20, "LAB3" => 20, "LAB4" => 30, "LAB5" => 40, "LAB6" => 50, "LAB7" => 50, "LAB8" => 200}

# Generating 10 rooms with capacity 30
(1..10).each { |i| rooms["R#{i}"] = 30 }

# Generating 10 rooms with capacity 50
(11..20).each { |i| rooms["R#{i}"] = 50 }

# Generating 10 rooms with capacity 100
(21..30).each { |i| rooms["R#{i}"] = 100 }

# Generating 5 rooms with capacity 200
(31..35).each { |i| rooms["R#{i}"] = 200 }

# Generating 5 rooms with capacity 300
(36..40).each { |i| rooms["R#{i}"] = 300 }

periods = (1..50).map {|room| room}.to_a
variables = $courses.to_a.to_h

domains = {}
variables.each_key do |var|
  domains[var] = { rooms: rooms.dup, periods: periods.dup }
end

domains.each do |course, d|
  if course.include?("LAB") #Lab lessons in Labs (duh)
    d[:rooms].select! do |room, capacity|
      room.include?("LAB") && capacity >= variables[course][:enrollment]
    end
  else
    d[:rooms].select! { |_room, capacity| capacity >= variables[course][:enrollment] }
  end
end


neighbors = {
  # albert's programming1 lecture and labs
  "CMPE140*1_LEC_1_1" => ["CMPE140*1_LAB_1_1"],
  "CMPE140*1_LAB_1_1" => ["CMPE140*1_LEC_1_1"],
  # Rahim's programming1 lecture and labs
  "CMPE140*1_LEC_2_1" => [
    "CMPE140*1_LAB_2_1",
    "CMPE140*1_LAB_2_2",
    "CMPE140*1_LAB_2_3",
    "CMPE140*1_LAB_2_4"
  ],
  "CMPE140*1_LAB_2_1" => ["CMPE140*1_LEC_2_1"],
  "CMPE140*1_LAB_2_2" => ["CMPE140*1_LEC_2_1"],
  "CMPE140*1_LAB_2_3" => ["CMPE140*1_LEC_2_1"],
  "CMPE140*1_LAB_2_4" => ["CMPE140*1_LEC_2_1"],
  #Albert programming2
  "CMPE241*1_LEC_1_1" => ["CMPE241*1_LAB_1_1", "CMPE241*1_LAB_1_2"],
  "CMPE241*1_LAB_1_1" => ["CMPE241*1_LEC_1_1"],
  "CMPE241*1_LAB_1_2" => ["CMPE241*1_LEC_1_1"],
  #Fabio data structures
  "CMPE242_LEC_1_1" => ["CMPE242_LAB_1_1"],
  "CMPE242_LAB_1_1" => ["CMPE242_LEC_1_1"],
  #Albert data structures
  "CMPE242_LEC_2_1" => ["CMPE242_LAB_2_1"],
  "CMPE242_LAB_2_1" => ["CMPE242_LEC_2_1"],
  #EEE104
  "EEE104_LEC_1_1" => ["EEE104_LAB_1_1"],
  "EEE104_LAB_1_1" => ["EEE104_LEC_1_1"],
  #EEE203
  "EEE203*1_LEC_1_1" => ["EEE203*1_LAB_1_1"],
  "EEE203*1_LAB_1_1" => ["EEE203*1_LEC_1_1"],
  #EEE204
  "EEE204*1_LEC_1_1" => ["EEE204*1_LAB_1_1", "EEE204*1_LAB_1_2"],
  "EEE204*1_LAB_1_1" => ["EEE204*1_LEC_1_1"],
  "EEE204*1_LAB_1_2" => ["EEE204*1_LEC_1_1"],
  #EEE304
  "EEE304*1_LEC_1_1" => ["EEE304*1_LAB_1_1"],
  "EEE304*1_LAB_1_1" => ["EEE304*1_LEC_1_1"],
  #EEE414
  "EEE414_LEC_1_1" => ["EEE414_LAB_1_1"],
  "EEE414_LAB_1_1" => ["EEE414_LEC_1_1"],

  #Haven't added arcs for MTE and MBG lecs and labs but they are being assigned correctly due to the course ordering nature in the hash
}

constraints = {
  #alberts programming1 constraints
  ["CMPE140*1_LEC_1_1", "CMPE140*1_LAB_1_1"] => lambda {|p1, p2| p1<p2},

  ["CMPE140*1_LAB_1_1", "CMPE140*1_LEC_1_1"] => lambda {|p2, p1| p2>p1},
  # Rahim's programming1 constraints
  ["CMPE140*1_LEC_2_1", "CMPE140*1_LAB_2_1"] => lambda { |p_lec, p_lab| p_lec < p_lab },
  ["CMPE140*1_LEC_2_1", "CMPE140*1_LAB_2_2"] => lambda { |p_lec, p_lab| p_lec < p_lab },
  ["CMPE140*1_LEC_2_1", "CMPE140*1_LAB_2_3"] => lambda { |p_lec, p_lab| p_lec < p_lab },
  ["CMPE140*1_LEC_2_1", "CMPE140*1_LAB_2_4"] => lambda { |p_lec, p_lab| p_lec < p_lab },

  ["CMPE140*1_LAB_2_1", "CMPE140*1_LEC_2_1"] => lambda { |p_lab, p_lec| p_lab > p_lec },
  ["CMPE140*1_LAB_2_2", "CMPE140*1_LEC_2_1"] => lambda { |p_lab, p_lec| p_lab > p_lec },
  ["CMPE140*1_LAB_2_3", "CMPE140*1_LEC_2_1"] => lambda { |p_lab, p_lec| p_lab > p_lec },
  ["CMPE140*1_LAB_2_4", "CMPE140*1_LEC_2_1"] => lambda { |p_lab, p_lec| p_lab > p_lec },

  #Albert programming 2
  ["CMPE241*1_LEC_1_1", "CMPE241*1_LAB_1_1"] => lambda { |p_lec, p_lab| p_lec < p_lab },
  ["CMPE241*1_LEC_1_1", "CMPE241*1_LAB_1_2"] => lambda { |p_lec, p_lab| p_lec < p_lab },

  ["CMPE241*1_LAB_1_1", "CMPE241*1_LEC_1_1"] => lambda { |p_lab, p_lec| p_lab > p_lec },
  ["CMPE241*1_LAB_1_2", "CMPE241*1_LEC_1_1"] => lambda { |p_lab, p_lec| p_lab > p_lec },

  # Fabio data structures constraints
  ["CMPE242_LEC_1_1", "CMPE242_LAB_1_1"] => lambda { |p_lec, p_lab| p_lec < p_lab },
  ["CMPE242_LAB_1_1", "CMPE242_LEC_1_1"] => lambda { |p_lab, p_lec| p_lab > p_lec },

  # Albert data structures constraints
  ["CMPE242_LEC_2_1", "CMPE242_LAB_2_1"] => lambda { |p_lec, p_lab| p_lec < p_lab },
  ["CMPE242_LAB_2_1", "CMPE242_LEC_2_1"] => lambda { |p_lab, p_lec| p_lab > p_lec },

  #EEE104
  ["EEE104_LEC_1_1", "EEE104_LAB_1_1"] => lambda { |p_lec, p_lab| p_lec < p_lab },
  ["EEE104_LAB_1_1", "EEE104_LEC_1_1"] => lambda { |p_lab, p_lec| p_lab > p_lec },

  #EEE203
  ["EEE203*1_LEC_1_1", "EEE203*1_LAB_1_1"] => lambda { |p_lec, p_lab| p_lec < p_lab },
  ["EEE203*1_LAB_1_1", "EEE203*1_LEC_1_1"] => lambda { |p_lab, p_lec| p_lab > p_lec },

  #EEE204
  ["EEE204*1_LEC_1_1", "EEE204*1_LAB_1_1"] => lambda { |p_lec, p_lab| p_lec < p_lab },
  ["EEE204*1_LAB_1_1", "EEE204*1_LEC_1_1"] => lambda { |p_lab, p_lec| p_lab > p_lec },

  ["EEE204*1_LEC_1_1", "EEE204*1_LAB_1_2"] => lambda { |p_lec, p_lab| p_lec < p_lab },
  ["EEE204*1_LAB_1_2", "EEE204*1_LEC_1_1"] => lambda { |p_lab, p_lec| p_lab > p_lec },

  #EEE304
  ["EEE304*1_LEC_1_1", "EEE304*1_LAB_1_1"] => lambda { |p_lec, p_lab| p_lec < p_lab },
  ["EEE304*1_LAB_1_1", "EEE304*1_LEC_1_1"] => lambda { |p_lab, p_lec| p_lab > p_lec },

  #EEE414
  ["EEE414_LEC_1_1", "EEE414_LAB_1_1"] => lambda { |p_lec, p_lab| p_lec < p_lab },
  ["EEE414_LAB_1_1", "EEE414_LEC_1_1"] => lambda { |p_lec, p_lab| p_lec > p_lab },
}


def ac3_periods(domains, neighbors, constraints)
  # our arcs
  queue = constraints.keys.dup

  # iterating through our arcs
  # noinspection RubyControlFlowConversionInspection (RUBOCOP)
  while !queue.empty?
    xi, xj = queue.shift # for every value of xi there must be a suitable value in xj
    if revise_period(xi, xj, domains, constraints[[xi, xj]])
      # No values remained (impossible problem)
      return false if domains[xi][:periods].empty?
      # For each neighbor of xi (except xj), add the arc (xk, xi) back into the queue.
      (neighbors[xi] || []).each do |xk|
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
def backtrack(assignment, course_data, domains, constraints, courses_in_period)
  # If all courses have been assigned, return the assignment.
  return assignment if assignment.keys.sort == course_data.keys.sort

  # Select an unassigned course (variable)
  var = course_data.keys.find { |v| !assignment.key?(v) }

  # For the chosen course, iterate over all possible values.
  # Here we iterate over rooms first and then periods.
  domains[var][:rooms].each_key do |room|
    domains[var][:periods].each do |period|
      value = { room: room, period: period }
      # Check if assigning this value to var is consistent with already made assignments.
      if consistent?(assignment, var, value, constraints, course_data, courses_in_period)
        # Add the assignment for var.
        assignment[var] = value
        # Update courses_in_period for quick group checks.
        courses_in_period[period] ||= []
        courses_in_period[period] << var

        # Recursively attempt to complete the assignment.
        result = backtrack(assignment, course_data, domains, constraints, courses_in_period)
        return result if result

        # Backtrack: remove the assignment and update courses_in_period.
        assignment.delete(var)
        courses_in_period[period].delete(var)
      end
    end
  end

  # No valid assignment found for this branch.
  nil
end

# Consistency check: ensure that assigning the given value to var doesn't violate constraints.
def consistent?(assignment, var, value, constraints, course_data, courses_in_period)
  # First, we check all the binary constraints already in the constraints hash and room/professor conflicts.
  assignment.each do |course, course_value|
    # Binary constraint checks (e.g., lecture-lab ordering, professor conflict)
    if constraints.key?([var, course])
      return false unless constraints[[var, course]].call(value[:period], course_value[:period])
    end
    if constraints.key?([course, var])
      return false unless constraints[[course, var]].call(course_value[:period], value[:period])
    end

    # Room conflict: two courses cannot share the same room at the same period.
    if course_value[:room] == value[:room] && course_value[:period] == value[:period]
      return false
    end

    # Professor conflict: if courses share the same professor, they should not be scheduled at the same period.
    if course_data[course][:professor] == course_data[var][:professor] &&
      course_value[:period] == value[:period]
      return false
    end
  end

  # Group constraint using the auxiliary hash:
  # CHEM
  if var.start_with?("CHEM")
    if courses_in_period[value[:period]]
      courses_in_period[value[:period]].each do |other_course|
        if other_course.start_with?("CHEM")
          return false
        end
      end
    end
  end

  #CMPE
  if var.start_with?("CMPE")
    if courses_in_period[value[:period]]
      courses_in_period[value[:period]].each do |other_course|
        if other_course.start_with?("CMPE")
          return false
        end
      end
    end
  end

  #CIV
  if var.start_with?("CIV")
    if courses_in_period[value[:period]]
      courses_in_period[value[:period]].each do |other_course|
        if other_course.start_with?("CIV")
          return false
        end
      end
    end
  end

  #EEE
  if var.start_with?("EEE")
    if courses_in_period[value[:period]]
      courses_in_period[value[:period]].each do |other_course|
        if other_course.start_with?("EEE")
          return false
        end
      end
    end
  end

  #FENS
  if var.start_with?("FENS")
    if courses_in_period[value[:period]]
      courses_in_period[value[:period]].each do |other_course|
        if other_course.start_with?("FENS")
          return false
        end
      end
    end
  end

  #INE
  if var.start_with?("INE")
    if courses_in_period[value[:period]]
      courses_in_period[value[:period]].each do |other_course|
        if other_course.start_with?("INE")
          return false
        end
      end
    end
  end

  #MBG
  if var.start_with?("MBG")
    if courses_in_period[value[:period]]
      courses_in_period[value[:period]].each do |other_course|
        if other_course.start_with?("MBG")
          return false
        end
      end
    end
  end

  #MTE
  if var.start_with?("MTE")
    if courses_in_period[value[:period]]
      courses_in_period[value[:period]].each do |other_course|
        if other_course.start_with?("MTE")
          return false
        end
      end
    end
  end

  true
end


solution = backtrack({}, variables, domains, constraints, {})

if solution
  puts "Backtracking succeeded. Final assignments:"
  solution.each do |course, value|
    puts "#{course}: Room #{value[:room]}, Period #{value[:period]}"
  end
else
  puts "No valid assignment found."
end
