require 'json'
courses = {}

# Read the file with each line chomped so that we don't have newlines.
lines = File.readlines('courses.txt', chomp: true)

# Process the file 5 lines at a time.
lines.each_slice(5) do |block|
  next if block.size < 5

  course_code = block[0].strip
  # course name is in block[1] but we don't use it
  raw_professor = block[2].strip
  timing = block[3].strip
  capacity = block[4].strip

  # Count the number of daily schedules by checking tokens like "MON", "TUE", etc.
  # We split on " - " and count entries starting with a day abbreviation.
  weekly = timing.split(' - ').count { |token| token.strip =~ /^(MON|TUE|WED|THU|FRI|SAT|SUN)/ }

  professor = raw_professor.downcase
  capacity_value = capacity.to_i

  entry = { professor: professor, weekly: weekly, capacity: capacity_value }

  # If the course code already exists, convert the value into an array of entries.
  if courses.key?(course_code)
    if courses[course_code].is_a?(Array)
      courses[course_code] << entry
    else
      courses[course_code] = [courses[course_code], entry]
    end
  else
    courses[course_code] = entry
  end
end

# Print the resulting hash to verify the output.
pretty = JSON.pretty_generate(courses)
File.write("courses(rich).json", pretty)