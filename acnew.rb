# ac3_scheduler_with_professor.rb
require_relative "parse3"
require "json"

# Room capacities
rooms = {
  "LAB1" => 20, "LAB2" => 20, "LAB3" => 20, "LAB4" => 30,
  "LAB5" => 40, "LAB6" => 50, "LAB7" => 50, "LAB8" => 200
}
(1..10).each  { |i| rooms["R#{i}"]  = 30 }
(11..20).each { |i| rooms["R#{i}"] = 50 }
(21..30).each { |i| rooms["R#{i}"] = 100 }
(31..35).each { |i| rooms["R#{i}"] = 200 }
(36..40).each { |i| rooms["R#{i}"] = 300 }

days = ["Mon", "Tue", "Wed", "Thu", "Fri"]

# Generate all valid period blocks for a given day and duration
def valid_period_blocks_for_day(day, duration)
  max_start = 23 - duration
  (1..max_start).map do |start_period|
    { day: day, start_period: start_period, duration: duration }
  end
end
MAX_PERIOD = 24

# Compute an integer ordering for blocks based on day and start period
def block_order(block)
  day_ord = { "Mon"=>0, "Tue"=>1, "Wed"=>2, "Thu"=>3, "Fri"=>4 }[block[:day]]
  day_ord * MAX_PERIOD + block[:start_period]
end

# Load course metadata (duration, enrollment, professor) from parse3
course_data = $courses_duration

# Build domains for each course
domains = {}
course_data.each_key do |course|
  dur = course_data[course][:duration]
  blocks = days.flat_map { |d| valid_period_blocks_for_day(d, dur) }
  domains[course] = { rooms: rooms.dup, period_blocks: blocks }
end

# Filter room domains by capacity and lab vs. lecture
domains.each do |course, d|
  if course.include?("LAB")
    d[:rooms].select! { |r,c| r.include?("LAB") && c >= course_data[course][:enrollment] }
  else
    d[:rooms].select! { |_r,c| c >= course_data[course][:enrollment] }
  end
end

# Binary constraints between lectures and their labs (lecture before lab)
constraints = {
  # CMPE140*1
  ["CMPE140*1_LEC_1_1", "CMPE140*1_LAB_1_1"] => ->(a,b){ block_order(a) < block_order(b) },
  ["CMPE140*1_LAB_1_1", "CMPE140*1_LEC_1_1"] => ->(b,a){ block_order(a) < block_order(b) },

  ["CMPE140*1_LEC_2_1", "CMPE140*1_LAB_2_1"] => ->(a,b){ block_order(a) < block_order(b) },
  ["CMPE140*1_LEC_2_1", "CMPE140*1_LAB_2_2"] => ->(a,b){ block_order(a) < block_order(b) },
  ["CMPE140*1_LEC_2_1", "CMPE140*1_LAB_2_3"] => ->(a,b){ block_order(a) < block_order(b) },
  ["CMPE140*1_LEC_2_1", "CMPE140*1_LAB_2_4"] => ->(a,b){ block_order(a) < block_order(b) },
  ["CMPE140*1_LAB_2_1", "CMPE140*1_LEC_2_1"] => ->(b,a){ block_order(a) < block_order(b) },
  ["CMPE140*1_LAB_2_2", "CMPE140*1_LEC_2_1"] => ->(b,a){ block_order(a) < block_order(b) },
  ["CMPE140*1_LAB_2_3", "CMPE140*1_LEC_2_1"] => ->(b,a){ block_order(a) < block_order(b) },
  ["CMPE140*1_LAB_2_4", "CMPE140*1_LEC_2_1"] => ->(b,a){ block_order(a) < block_order(b) },

  # CMPE241*1
  ["CMPE241*1_LEC_1_1", "CMPE241*1_LAB_1_1"] => ->(a,b){ block_order(a) < block_order(b) },
  ["CMPE241*1_LEC_1_1", "CMPE241*1_LAB_1_2"] => ->(a,b){ block_order(a) < block_order(b) },
  ["CMPE241*1_LAB_1_1", "CMPE241*1_LEC_1_1"] => ->(b,a){ block_order(a) < block_order(b) },
  ["CMPE241*1_LAB_1_2", "CMPE241*1_LEC_1_1"] => ->(b,a){ block_order(a) < block_order(b) },

  # CMPE242
  ["CMPE242_LEC_1_1", "CMPE242_LAB_1_1"] => ->(a,b){ block_order(a) < block_order(b) },
  ["CMPE242_LAB_1_1", "CMPE242_LEC_1_1"] => ->(b,a){ block_order(a) < block_order(b) },
  ["CMPE242_LEC_2_1", "CMPE242_LAB_2_1"] => ->(a,b){ block_order(a) < block_order(b) },
  ["CMPE242_LAB_2_1", "CMPE242_LEC_2_1"] => ->(b,a){ block_order(a) < block_order(b) },

  # EEE104
  ["EEE104_LEC_1_1", "EEE104_LAB_1_1"] => ->(a,b){ block_order(a) < block_order(b) },
  ["EEE104_LAB_1_1", "EEE104_LEC_1_1"] => ->(b,a){ block_order(a) < block_order(b) },

  # EEE203
  ["EEE203*1_LEC_1_1", "EEE203*1_LAB_1_1"] => ->(a,b){ block_order(a) < block_order(b) },
  ["EEE203*1_LAB_1_1", "EEE203*1_LEC_1_1"] => ->(b,a){ block_order(a) < block_order(b) },

  # EEE204
  ["EEE204*1_LEC_1_1", "EEE204*1_LAB_1_1"] => ->(a,b){ block_order(a) < block_order(b) },
  ["EEE204*1_LAB_1_1", "EEE204*1_LEC_1_1"] => ->(b,a){ block_order(a) < block_order(b) },
  ["EEE204*1_LEC_1_1", "EEE204*1_LAB_1_2"] => ->(a,b){ block_order(a) < block_order(b) },
  ["EEE204*1_LAB_1_2", "EEE204*1_LEC_1_1"] => ->(b,a){ block_order(a) < block_order(b) },

  # EEE304
  ["EEE304*1_LEC_1_1", "EEE304*1_LAB_1_1"] => ->(a,b){ block_order(a) < block_order(b) },
  ["EEE304*1_LAB_1_1", "EEE304*1_LEC_1_1"] => ->(b,a){ block_order(a) < block_order(b) },

  # EEE414
  ["EEE414_LEC_1_1", "EEE414_LAB_1_1"] => ->(a,b){ block_order(a) < block_order(b) },
  ["EEE414_LAB_1_1", "EEE414_LEC_1_1"] => ->(b,a){ block_order(a) < block_order(b) },


  ["MBG212_LEC_1_1", "MBG212_LAB_1_1"] => ->(a,b){ block_order(a) < block_order(b) },
  ["MBG212_LAB_1_1", "MBG212_LEC_1_1"] => ->(b,a){ block_order(a) < block_order(b) }
}



# Neighboring relations for AC-3
neighbors = {}
constraints.keys.each do |(xi,xj)|
  (neighbors[xi] ||= []) << xj
end

# AC-3 algorithm for period_blocks

def ac3_period_blocks(domains, neighbors, constraints)
  queue = constraints.keys.dup
  while queue.any?
    xi,xj = queue.shift
    next unless domains[xi] && domains[xj]
    if revise(xi,xj,domains,constraints[[xi,xj]])
      return false if domains[xi][:period_blocks].empty?
      (neighbors[xi] || []).each { |xk| queue << [xk,xi] unless xk == xj }
    end
  end
  domains
end

def revise(xi,xj,domains,constraint)
  revised = false
  domains[xi][:period_blocks].dup.each do |b|
    unless domains[xj][:period_blocks].any? { |b2| constraint.call(b,b2) }
      domains[xi][:period_blocks].delete(b)
      revised = true
    end
  end
  revised
end


# Backtracking search

def course_year(course)
  course.match(/^[A-Z]+(\d)/)&.[](1)
end

def consistent?(assign, var, val, cons, data, in_period)
  block = val[:period_block]
  slots = (block[:start_period]...(block[:start_period]+block[:duration])).map { |p| { day:block[:day], period:p } }

  assign.each do |other,ov|
    # Binary constraints
    if cons[[var,other]] && !cons[[var,other]].call(block,ov[:period_block])
      return false
    end
    if cons[[other,var]] && !cons[[other,var]].call(ov[:period_block],block)
      return false
    end
    # Room conflict
    if ov[:room] == val[:room]
      other_slots = (ov[:period_block][:start_period]...(ov[:period_block][:start_period]+ov[:period_block][:duration])).map { |p| { day:ov[:period_block][:day], period:p } }
      return false if (slots & other_slots).any?
    end
    # Professor conflict
    if data[other][:professor] == data[var][:professor]
      other_slots = (ov[:period_block][:start_period]...(ov[:period_block][:start_period]+ov[:period_block][:duration])).map { |p| { day:ov[:period_block][:day], period:p } }
      return false if (slots & other_slots).any?
    end
  end
  # Group constraints
  %w[CHEM CMPE CIV EEE FENS INE MBG MTE].each do |pref|
    if var.start_with?(pref)
      y = course_year(var)
      slots.each do |s|
        if in_period[s]
          in_period[s].each do |oc|
            if oc.start_with?(pref) && course_year(oc)==y
              return false
            end
          end
        end
      end
    end
  end
  true
end

def backtrack(assign, data, domains, cons, in_period)
  return assign if assign.keys.sort==data.keys.sort
  var = data.keys.find{|c|!assign.key?(c)}
  domains[var][:rooms].each_key do |r|
    domains[var][:period_blocks].each do |b|
      cand = { room: r, period_block: b }
      if consistent?(assign,var,cand,cons,data,in_period)
        assign[var]=cand
        # mark slots
        slots = (b[:start_period]...(b[:start_period]+b[:duration])).map{|p|{day:b[:day],period:p}}
        slots.each { |s| (in_period[s]||=[] )<<var }
        res=backtrack(assign,data,domains,cons,in_period)
        return res if res
        assign.delete(var)
        slots.each { |s| in_period[s].delete(var) }
      end
    end
  end
  nil
end


# Run AC-3 then backtracking
ac3_res = ac3_period_blocks(domains,neighbors,constraints)
unless ac3_res
  puts "AC-3 consistency check failed."
  exit
end
solution = backtrack({},course_data,domains,constraints,{})

if solution
  day_to_index = { "Mon"=>1, "Tue"=>2, "Wed"=>3, "Thu"=>4, "Fri"=>5 }
  output = {}
  solution.each do |course,val|
    b=val[:period_block]; sp=b[:start_period]; ep=sp+b[:duration]-1
    output[course] = {
      "time"       => { "day"=>day_to_index[b[:day]], "period"=>"#{sp}-#{ep}" },
      "room"       => val[:room],
      "professor"  => course_data[course][:professor],
      "enrollment" => course_data[course][:enrollment]
    }

  end
  File.write("ac3-solution.json",JSON.pretty_generate(output))
  puts "Solution saved to ac3-solution.json"
else
  puts "No valid assignment found."
end



professors = $courses_duration.values.map { |cd| cd[:professor] }.uniq

export = {
  courses: domains.keys,
  rooms: rooms,                                # { "LAB1" => 20, … }
  domains: domains.transform_values do |d|     # domains after AC-3
    {
      rooms:    d[:rooms].keys,
      blocks:   d[:period_blocks].map { |b| [b[:day], b[:start_period], b[:duration]] }
    }
  end,
  prof_of:   $courses_duration.transform_values { |cd| cd[:professor] },
  max_gap:   Hash[professors.map { |p| [p, 2] }]  # e.g. each prof prefers ≤2-slot gaps
}

#File.write("pruned.json", JSON.pretty_generate(export))

File.write("rooms.json", JSON.pretty_generate(rooms))