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

# Define days and generate periods as day/period pairs.
days = ["Mon", "Tue", "Wed", "Thu", "Fri"]
# Each day has 10 periods so overall we still have 50 period slots.
periods = days.flat_map do |day|
  (1..10).map { |p| { day: day, period: p } }
end

# A helper method to compare periods. This assigns each period a unique integer based on day order. 10-60
def period_order(p)
  day_order = {"Mon" => 1, "Tue" => 2, "Wed" => 3, "Thu" => 4, "Fri" => 5}
  day_order[p[:day]] * 10 + p[:period]
end

variables = $courses.to_a.to_h

domains = {}
variables.each_key do |var|
  # Duplicate rooms and periods domains for each course.
  domains[var] = { rooms: rooms.dup, periods: periods.dup }
end

domains.each do |course, d|
  if course.include?("LAB") # Lab lessons must be in LAB rooms with sufficient capacity.
    d[:rooms].select! do |room, capacity|
      room.include?("LAB") && capacity >= variables[course][:enrollment]
    end
  else
    d[:rooms].select! { |_room, capacity| capacity >= variables[course][:enrollment] }
  end
end

# constraint lambda compare periods using period_order method.
constraints = {
  # Albert's programming1 lecture and lab
  ["CMPE140*1_LEC_1_1", "CMPE140*1_LAB_1_1"] => lambda { |p1, p2| period_order(p1) < period_order(p2) },
  ["CMPE140*1_LAB_1_1", "CMPE140*1_LEC_1_1"] => lambda { |p2, p1| period_order(p2) > period_order(p1) },
  # Rahim's programming1 lecture and labs
  ["CMPE140*1_LEC_2_1", "CMPE140*1_LAB_2_1"] => lambda { |p_lec, p_lab| period_order(p_lec) < period_order(p_lab) },
  ["CMPE140*1_LEC_2_1", "CMPE140*1_LAB_2_2"] => lambda { |p_lec, p_lab| period_order(p_lec) < period_order(p_lab) },
  ["CMPE140*1_LEC_2_1", "CMPE140*1_LAB_2_3"] => lambda { |p_lec, p_lab| period_order(p_lec) < period_order(p_lab) },
  ["CMPE140*1_LEC_2_1", "CMPE140*1_LAB_2_4"] => lambda { |p_lec, p_lab| period_order(p_lec) < period_order(p_lab) },
  ["CMPE140*1_LAB_2_1", "CMPE140*1_LEC_2_1"] => lambda { |p_lab, p_lec| period_order(p_lab) > period_order(p_lec) },
  ["CMPE140*1_LAB_2_2", "CMPE140*1_LEC_2_1"] => lambda { |p_lab, p_lec| period_order(p_lab) > period_order(p_lec) },
  ["CMPE140*1_LAB_2_3", "CMPE140*1_LEC_2_1"] => lambda { |p_lab, p_lec| period_order(p_lab) > period_order(p_lec) },
  ["CMPE140*1_LAB_2_4", "CMPE140*1_LEC_2_1"] => lambda { |p_lab, p_lec| period_order(p_lab) > period_order(p_lec) },
  # Albert's programming2 lecture and labs
  ["CMPE241*1_LEC_1_1", "CMPE241*1_LAB_1_1"] => lambda { |p_lec, p_lab| period_order(p_lec) < period_order(p_lab) },
  ["CMPE241*1_LEC_1_1", "CMPE241*1_LAB_1_2"] => lambda { |p_lec, p_lab| period_order(p_lec) < period_order(p_lab) },
  ["CMPE241*1_LAB_1_1", "CMPE241*1_LEC_1_1"] => lambda { |p_lab, p_lec| period_order(p_lab) > period_order(p_lec) },
  ["CMPE241*1_LAB_1_2", "CMPE241*1_LEC_1_1"] => lambda { |p_lab, p_lec| period_order(p_lab) > period_order(p_lec) },
  # Fabio data structures
  ["CMPE242_LEC_1_1", "CMPE242_LAB_1_1"] => lambda { |p_lec, p_lab| period_order(p_lec) < period_order(p_lab) },
  ["CMPE242_LAB_1_1", "CMPE242_LEC_1_1"] => lambda { |p_lab, p_lec| period_order(p_lab) > period_order(p_lec) },
  # Albert data structures
  ["CMPE242_LEC_2_1", "CMPE242_LAB_2_1"] => lambda { |p_lec, p_lab| period_order(p_lec) < period_order(p_lab) },
  ["CMPE242_LAB_2_1", "CMPE242_LEC_2_1"] => lambda { |p_lab, p_lec| period_order(p_lab) > period_order(p_lec) },
  # EEE104
  ["EEE104_LEC_1_1", "EEE104_LAB_1_1"] => lambda { |p_lec, p_lab| period_order(p_lec) < period_order(p_lab) },
  ["EEE104_LAB_1_1", "EEE104_LEC_1_1"] => lambda { |p_lab, p_lec| period_order(p_lab) > period_order(p_lec) },
  # EEE203
  ["EEE203*1_LEC_1_1", "EEE203*1_LAB_1_1"] => lambda { |p_lec, p_lab| period_order(p_lec) < period_order(p_lab) },
  ["EEE203*1_LAB_1_1", "EEE203*1_LEC_1_1"] => lambda { |p_lab, p_lec| period_order(p_lab) > period_order(p_lec) },
  # EEE204
  ["EEE204*1_LEC_1_1", "EEE204*1_LAB_1_1"] => lambda { |p_lec, p_lab| period_order(p_lec) < period_order(p_lab) },
  ["EEE204*1_LAB_1_1", "EEE204*1_LEC_1_1"] => lambda { |p_lab, p_lec| period_order(p_lab) > period_order(p_lec) },
  ["EEE204*1_LEC_1_1", "EEE204*1_LAB_1_2"] => lambda { |p_lec, p_lab| period_order(p_lec) < period_order(p_lab) },
  ["EEE204*1_LAB_1_2", "EEE204*1_LEC_1_1"] => lambda { |p_lab, p_lec| period_order(p_lab) > period_order(p_lec) },
  # EEE304
  ["EEE304*1_LEC_1_1", "EEE304*1_LAB_1_1"] => lambda { |p_lec, p_lab| period_order(p_lec) < period_order(p_lab) },
  ["EEE304*1_LAB_1_1", "EEE304*1_LEC_1_1"] => lambda { |p_lab, p_lec| period_order(p_lab) > period_order(p_lec) },
  # EEE414
  ["EEE414_LEC_1_1", "EEE414_LAB_1_1"] => lambda { |p_lec, p_lab| period_order(p_lec) < period_order(p_lab) },
  ["EEE414_LAB_1_1", "EEE414_LEC_1_1"] => lambda { |p_lab, p_lec| period_order(p_lab) > period_order(p_lec) },
}

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
  # Albert programming2
  "CMPE241*1_LEC_1_1" => ["CMPE241*1_LAB_1_1", "CMPE241*1_LAB_1_2"],
  "CMPE241*1_LAB_1_1" => ["CMPE241*1_LEC_1_1"],
  "CMPE241*1_LAB_1_2" => ["CMPE241*1_LEC_1_1"],
  # Fabio data structures
  "CMPE242_LEC_1_1" => ["CMPE242_LAB_1_1"],
  "CMPE242_LAB_1_1" => ["CMPE242_LEC_1_1"],
  # Albert data structures
  "CMPE242_LEC_2_1" => ["CMPE242_LAB_2_1"],
  "CMPE242_LAB_2_1" => ["CMPE242_LEC_2_1"],
  # EEE104
  "EEE104_LEC_1_1" => ["EEE104_LAB_1_1"],
  "EEE104_LAB_1_1" => ["EEE104_LEC_1_1"],
  # EEE203
  "EEE203*1_LEC_1_1" => ["EEE203*1_LAB_1_1"],
  "EEE203*1_LAB_1_1" => ["EEE203*1_LEC_1_1"],
  # EEE204
  "EEE204*1_LEC_1_1" => ["EEE204*1_LAB_1_1", "EEE204*1_LAB_1_2"],
  "EEE204*1_LAB_1_1" => ["EEE204*1_LEC_1_1"],
  "EEE204*1_LAB_1_2" => ["EEE204*1_LEC_1_1"],
  # EEE304
  "EEE304*1_LEC_1_1" => ["EEE304*1_LAB_1_1"],
  "EEE304*1_LAB_1_1" => ["EEE304*1_LEC_1_1"],
  # EEE414
  "EEE414_LEC_1_1" => ["EEE414_LAB_1_1"],
  "EEE414_LAB_1_1" => ["EEE414_LEC_1_1"],
  # Additional arcs for MTE and MBG are omitted for brevity. (They observe the constraint anyways due to their order)
}

# AC3 propagation for the :periods domain.
def ac3_periods(domains, neighbors, constraints)
  queue = constraints.keys.dup
  while !queue.empty?
    xi, xj = queue.shift
    if revise_period(xi, xj, domains, constraints[[xi, xj]])
      return false if domains[xi][:periods].empty?
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
  domains[xi][:periods].dup.each do |p|
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

# Backtracking search to assign each course a room and a period.
def backtrack(assignment, course_data, domains, constraints, courses_in_period)
  return assignment if assignment.keys.sort == course_data.keys.sort

  var = course_data.keys.find { |v| !assignment.key?(v) }
  domains[var][:rooms].each_key do |room|
    domains[var][:periods].each do |period|
      value = { room: room, period: period }
      if consistent?(assignment, var, value, constraints, course_data, courses_in_period)
        assignment[var] = value
        courses_in_period[period] ||= []
        courses_in_period[period] << var

        result = backtrack(assignment, course_data, domains, constraints, courses_in_period)
        return result if result

        assignment.delete(var)
        courses_in_period[period].delete(var)
      end
    end
  end
  nil
end

# Consistency check for room and period assignments.
def consistent?(assignment, var, value, constraints, course_data, courses_in_period)
  assignment.each do |course, course_value|
    if constraints.key?([var, course])
      return false unless constraints[[var, course]].call(value[:period], course_value[:period])
    end
    if constraints.key?([course, var])
      return false unless constraints[[course, var]].call(course_value[:period], value[:period])
    end

    if course_value[:room] == value[:room] && value[:period] == course_value[:period]
      return false
    end

    if course_data[course][:professor] == course_data[var][:professor] &&
       course_value[:period] == value[:period]
      return false
    end
  end

  # Group constraints: ensuring only one course per group in a given period.
  %w[CHEM CMPE CIV EEE FENS INE MBG MTE].each do |prefix|
    if var.start_with?(prefix) && courses_in_period[value[:period]]
      courses_in_period[value[:period]].each do |other_course|
        return false if other_course.start_with?(prefix)
      end
    end
  end

  true
end

solution = backtrack({}, variables, domains, constraints, {})

if solution
  puts "Backtracking succeeded. Final assignments:"
  solution.each do |course, value|
    # Format the output to show day and period.
    puts "#{course}: Room #{value[:room]}, Day #{value[:period][:day]}, Period #{value[:period][:period]}"
  end
else
  puts "No valid assignment found."
end

puts period_order({:day=>"Tue", :period=>4})