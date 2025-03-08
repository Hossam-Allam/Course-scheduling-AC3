require 'json'

# --- Step 1: Parse JSON and create lecture variables ---
file_path = 'courses.json'
course_lectures = JSON.parse(File.read(file_path))

# Create a hash mapping each course to an array of lecture names.
variables = {}
course_lectures.each do |course, count|
  variables[course] = (1..count).map { |i| "#{course}_#{i}" }
end

# Flatten the variables into a single array.
all_vars = variables.values.flatten

# --- Step 2: Build explicit same-course constraints ---
# For every course, for every pair of its lectures, add a constraint that they must not overlap.
constraints = []
variables.each do |course, lectures|
  lectures.combination(2) do |lec1, lec2|
    constraints << [lec1, lec2]
  end
end

arcs = {}


# --- Step 3: Set up the domain for each lecture ---
# Each lecture can be scheduled in one of 40 rooms and has a start period from 1 to 17.
rooms = (1..40).to_a
start_periods = (1..17).to_a  # Lecture takes 4 periods; so period 17 is the last valid start.
base_domain = rooms.product(start_periods)  # [room, start_period] pairs.

