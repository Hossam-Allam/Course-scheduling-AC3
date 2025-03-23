require_relative "parse3"

# Labs for labs 0-0
rooms = {
  "LAB1" => 20, "LAB2" => 20, "LAB3" => 20, "LAB4" => 30,
  "LAB5" => 40, "LAB6" => 50, "LAB7" => 50, "LAB8" => 200
}

# Normal rooms
(1..10).each { |i| rooms["R#{i}"] = 30 }
(11..20).each { |i| rooms["R#{i}"] = 50 }
(21..30).each { |i| rooms["R#{i}"] = 100 }
(31..35).each { |i| rooms["R#{i}"] = 200 }
(36..40).each { |i| rooms["R#{i}"] = 300 }

# Da Days
days = ["Mon", "Tue", "Wed", "Thu", "Fri"]

# For each day, given a course's duration, this method generates all valid blocks
# For example, on a day with 10 periods and duration 2, valid blocks are:
#   { day: "Mon", start_period: 1, duration: 2 } through { day: "Mon", start_period: 8, duration: 2 }
def valid_period_blocks_for_day(day, duration)
  (1..(23 - duration)).map do |start_period|
    { day: day, start_period: start_period, duration: duration }
  end
end

# A helper method to convert a block into an ordering integer (based on the start period).
def block_order(block)
  day_order = {"Mon" => 1, "Tue" => 2, "Wed" => 3, "Thu" => 4, "Fri" => 5}
  day_order[block[:day]] * 10 + block[:start_period]
end

# Assume $courses is already loaded from your parse file.
# Convert it into a hash mapping course name to its properties.
variables = $courses_duration

# Build the domain for each course:
#   - Rooms: filter later by capacity (and labs)
#   - Period blocks: for each day, all blocks that fit the course's duration.
domains = {}
variables.each_key do |course|
  duration = variables[course][:duration]
  period_blocks = days.flat_map { |day| valid_period_blocks_for_day(day, duration) }
  domains[course] = { rooms: rooms.dup, period_blocks: period_blocks }
end

# For each course, filter the room domain based on capacity and lecture type (normal or lab).
domains.each do |course, d|
  if course.include?("LAB")
    d[:rooms].select! { |room, capacity| room.include?("LAB") && capacity >= variables[course][:enrollment] }
  else
    d[:rooms].select! { |_room, capacity| capacity >= variables[course][:enrollment] }
  end
end

# Updated constraints to compare blocks by the starting period (using block_order).
constraints = {
  # Albert's programming1 lecture and lab
  ["CMPE140*1_LEC_1_1", "CMPE140*1_LAB_1_1"] => lambda { |b1, b2| block_order(b1) < block_order(b2) },
  ["CMPE140*1_LAB_1_1", "CMPE140*1_LEC_1_1"] => lambda { |b2, b1| block_order(b2) > block_order(b1) },
  # Rahim's programming1 lecture and labs
  ["CMPE140*1_LEC_2_1", "CMPE140*1_LAB_2_1"] => lambda { |b_lec, b_lab| block_order(b_lec) < block_order(b_lab) },
  ["CMPE140*1_LEC_2_1", "CMPE140*1_LAB_2_2"] => lambda { |b_lec, b_lab| block_order(b_lec) < block_order(b_lab) },
  ["CMPE140*1_LEC_2_1", "CMPE140*1_LAB_2_3"] => lambda { |b_lec, b_lab| block_order(b_lec) < block_order(b_lab) },
  ["CMPE140*1_LEC_2_1", "CMPE140*1_LAB_2_4"] => lambda { |b_lec, b_lab| block_order(b_lec) < block_order(b_lab) },
  ["CMPE140*1_LAB_2_1", "CMPE140*1_LEC_2_1"] => lambda { |b_lab, b_lec| block_order(b_lab) > block_order(b_lec) },
  ["CMPE140*1_LAB_2_2", "CMPE140*1_LEC_2_1"] => lambda { |b_lab, b_lec| block_order(b_lab) > block_order(b_lec) },
  ["CMPE140*1_LAB_2_3", "CMPE140*1_LEC_2_1"] => lambda { |b_lab, b_lec| block_order(b_lab) > block_order(b_lec) },
  ["CMPE140*1_LAB_2_4", "CMPE140*1_LEC_2_1"] => lambda { |b_lab, b_lec| block_order(b_lab) > block_order(b_lec) },
  # Albert programming2
  ["CMPE241*1_LEC_1_1", "CMPE241*1_LAB_1_1"] => lambda { |b_lec, b_lab| block_order(b_lec) < block_order(b_lab) },
  ["CMPE241*1_LEC_1_1", "CMPE241*1_LAB_1_2"] => lambda { |b_lec, b_lab| block_order(b_lec) < block_order(b_lab) },
  ["CMPE241*1_LAB_1_1", "CMPE241*1_LEC_1_1"] => lambda { |b_lab, b_lec| block_order(b_lab) > block_order(b_lec) },
  ["CMPE241*1_LAB_1_2", "CMPE241*1_LEC_1_1"] => lambda { |b_lab, b_lec| block_order(b_lab) > block_order(b_lec) },
  # Fabio data structures
  ["CMPE242_LEC_1_1", "CMPE242_LAB_1_1"] => lambda { |b_lec, b_lab| block_order(b_lec) < block_order(b_lab) },
  ["CMPE242_LAB_1_1", "CMPE242_LEC_1_1"] => lambda { |b_lab, b_lec| block_order(b_lab) > block_order(b_lec) },
  # Albert data structures
  ["CMPE242_LEC_2_1", "CMPE242_LAB_2_1"] => lambda { |b_lec, b_lab| block_order(b_lec) < block_order(b_lab) },
  ["CMPE242_LAB_2_1", "CMPE242_LEC_2_1"] => lambda { |b_lab, b_lec| block_order(b_lab) > block_order(b_lec) },
  # EEE104
  ["EEE104_LEC_1_1", "EEE104_LAB_1_1"] => lambda { |b_lec, b_lab| block_order(b_lec) < block_order(b_lab) },
  ["EEE104_LAB_1_1", "EEE104_LEC_1_1"] => lambda { |b_lab, b_lec| block_order(b_lab) > block_order(b_lec) },
  # EEE203
  ["EEE203*1_LEC_1_1", "EEE203*1_LAB_1_1"] => lambda { |b_lec, b_lab| block_order(b_lec) < block_order(b_lab) },
  ["EEE203*1_LAB_1_1", "EEE203*1_LEC_1_1"] => lambda { |b_lab, b_lec| block_order(b_lab) > block_order(b_lec) },
  # EEE204
  ["EEE204*1_LEC_1_1", "EEE204*1_LAB_1_1"] => lambda { |b_lec, b_lab| block_order(b_lec) < block_order(b_lab) },
  ["EEE204*1_LAB_1_1", "EEE204*1_LEC_1_1"] => lambda { |b_lab, b_lec| block_order(b_lab) > block_order(b_lec) },
  ["EEE204*1_LEC_1_1", "EEE204*1_LAB_1_2"] => lambda { |b_lec, b_lab| block_order(b_lec) < block_order(b_lab) },
  ["EEE204*1_LAB_1_2", "EEE204*1_LEC_1_1"] => lambda { |b_lab, b_lec| block_order(b_lab) > block_order(b_lec) },
  # EEE304
  ["EEE304*1_LEC_1_1", "EEE304*1_LAB_1_1"] => lambda { |b_lec, b_lab| block_order(b_lec) < block_order(b_lab) },
  ["EEE304*1_LAB_1_1", "EEE304*1_LEC_1_1"] => lambda { |b_lab, b_lec| block_order(b_lab) > block_order(b_lec) },
  # EEE414
  ["EEE414_LEC_1_1", "EEE414_LAB_1_1"] => lambda { |b_lec, b_lab| block_order(b_lec) < block_order(b_lab) },
  ["EEE414_LAB_1_1", "EEE414_LEC_1_1"] => lambda { |b_lab, b_lec| block_order(b_lab) > block_order(b_lec) },
}

# courses bounded by lecture -> lab constraints
neighbors = {
  "CMPE140*1_LEC_1_1" => ["CMPE140*1_LAB_1_1"],
  "CMPE140*1_LAB_1_1" => ["CMPE140*1_LEC_1_1"],
  "CMPE140*1_LEC_2_1" => ["CMPE140*1_LAB_2_1", "CMPE140*1_LAB_2_2", "CMPE140*1_LAB_2_3", "CMPE140*1_LAB_2_4"],
  "CMPE140*1_LAB_2_1" => ["CMPE140*1_LEC_2_1"],
  "CMPE140*1_LAB_2_2" => ["CMPE140*1_LEC_2_1"],
  "CMPE140*1_LAB_2_3" => ["CMPE140*1_LEC_2_1"],
  "CMPE140*1_LAB_2_4" => ["CMPE140*1_LEC_2_1"],
  "CMPE241*1_LEC_1_1" => ["CMPE241*1_LAB_1_1", "CMPE241*1_LAB_1_2"],
  "CMPE241*1_LAB_1_1" => ["CMPE241*1_LEC_1_1"],
  "CMPE241*1_LAB_1_2" => ["CMPE241*1_LEC_1_1"],
  "CMPE242_LEC_1_1" => ["CMPE242_LAB_1_1"],
  "CMPE242_LAB_1_1" => ["CMPE242_LEC_1_1"],
  "CMPE242_LEC_2_1" => ["CMPE242_LAB_2_1"],
  "CMPE242_LAB_2_1" => ["CMPE242_LEC_2_1"],
  "EEE104_LEC_1_1" => ["EEE104_LAB_1_1"],
  "EEE104_LAB_1_1" => ["EEE104_LEC_1_1"],
  "EEE203*1_LEC_1_1" => ["EEE203*1_LAB_1_1"],
  "EEE203*1_LAB_1_1" => ["EEE203*1_LEC_1_1"],
  "EEE204*1_LEC_1_1" => ["EEE204*1_LAB_1_1", "EEE204*1_LAB_1_2"],
  "EEE204*1_LAB_1_1" => ["EEE204*1_LEC_1_1"],
  "EEE204*1_LAB_1_2" => ["EEE204*1_LEC_1_1"],
  "EEE304*1_LEC_1_1" => ["EEE304*1_LAB_1_1"],
  "EEE304*1_LAB_1_1" => ["EEE304*1_LEC_1_1"],
  "EEE414_LEC_1_1" => ["EEE414_LAB_1_1"],
  "EEE414_LAB_1_1" => ["EEE414_LEC_1_1"],
}

# AC3 propagation for period blocks.
def ac3_period_blocks(domains, neighbors, constraints)
  queue = constraints.keys.dup
  while !queue.empty?
    xi, xj = queue.shift
    # Skip if either variable is missing from domains
    next unless domains[xi] && domains[xj]
    if revise_period_block(xi, xj, domains, constraints[[xi, xj]])
      return false if domains[xi][:period_blocks].empty?
      (neighbors[xi] || []).each do |xk|
        queue << [xk, xi] if xk != xj
      end
    end
  end
  domains
end

def revise_period_block(xi, xj, domains, constraint)
  revised = false
  domains[xi][:period_blocks].dup.each do |block|
    unless domains[xj][:period_blocks].any? { |other_block| constraint.call(block, other_block) }
      domains[xi][:period_blocks].delete(block)
      revised = true
    end
  end
  revised
end

ac3_result = ac3_period_blocks(domains, neighbors, constraints)
unless ac3_result
  puts "AC3 failed to find a consistent assignment."
  exit
end

# Backtracking search: assign each course a room and a period block.
def backtrack(assignment, course_data, domains, constraints, courses_in_period)
  return assignment if assignment.keys.sort == course_data.keys.sort

  var = course_data.keys.find { |v| !assignment.key?(v) }
  domains[var][:rooms].each_key do |room|
    domains[var][:period_blocks].each do |block|
      value = { room: room, period_block: block }
      if consistent?(assignment, var, value, constraints, course_data, courses_in_period)
        assignment[var] = value
        # Mark each individual slot in the block as occupied
        block_slots = (block[:start_period]...(block[:start_period] + block[:duration])).map do |p|
          { day: block[:day], period: p }
        end
        block_slots.each do |slot|
          courses_in_period[slot] ||= []
          courses_in_period[slot] << var
        end

        result = backtrack(assignment, course_data, domains, constraints, courses_in_period)
        return result if result

        assignment.delete(var)
        block_slots.each do |slot|
          courses_in_period[slot].delete(var)
        end
      end
    end
  end
  nil
end

def course_year(course)
  if match = course.match(/^[A-Z]+(\d)/)
    match[1]
  else
    nil
  end
end

# Consistency check: ensure no conflicts (room, professor, binary constraints, and group conflicts).
def consistent?(assignment, var, value, constraints, course_data, courses_in_period)
  block = value[:period_block]
  block_slots = (block[:start_period]...(block[:start_period] + block[:duration])).map do |p|
    { day: block[:day], period: p }
  end

  assignment.each do |other_course, other_value|
    # Check binary constraints using block_order
    if constraints.key?([var, other_course])
      return false unless constraints[[var, other_course]].call(value[:period_block], other_value[:period_block])
    end
    if constraints.key?([other_course, var])
      return false unless constraints[[other_course, var]].call(other_value[:period_block], value[:period_block])
    end

    # Room conflict: if the room is the same, ensure no overlapping slots.
    if other_value[:room] == value[:room]
      other_block = other_value[:period_block]
      other_slots = (other_block[:start_period]...(other_block[:start_period] + other_block[:duration])).map do |p|
        { day: other_block[:day], period: p }
      end
      return false if (block_slots & other_slots).any?
    end

    # Professor conflict: same professor cannot be in overlapping slots.
    if course_data[other_course][:professor] == course_data[var][:professor]
      other_block = other_value[:period_block]
      other_slots = (other_block[:start_period]...(other_block[:start_period] + other_block[:duration])).map do |p|
        { day: other_block[:day], period: p }
      end
      return false if (block_slots & other_slots).any?
    end
  end

  # Group constraints: ensure only one course per group per period.
  %w[CHEM CMPE CIV EEE FENS INE MBG MTE].each do |prefix|
    if var.start_with?(prefix)
      current_year = course_year(var)
      block_slots.each do |slot|
        if courses_in_period[slot]
          courses_in_period[slot].each do |other_course|
            if other_course.start_with?(prefix) && course_year(other_course) == current_year
              return false
            end
          end
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
    block = value[:period_block]
    puts "#{course}: Room #{value[:room]}, Day #{block[:day]}, Periods #{block[:start_period]}-#{block[:start_period] + block[:duration] - 1}"
  end
else
  puts "No valid assignment found."
end
