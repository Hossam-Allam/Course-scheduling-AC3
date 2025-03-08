require 'json'

# Read and parse the JSON file.
raw_data = JSON.parse(File.read("courses(rich).json"))

# Normalized courses hash that our scheduling algorithm can use.
# We'll call it `courses` (which replaces our old `variables`).
$courses = {}

raw_data.each do |course_code, data|
  if data.is_a?(Array)
    # Multiple sessions (likely due to multiple professors or split sections)
    data.each_with_index do |session, prof_index|
      session["weekly"].times do |week_index|
        key = "#{course_code}_#{prof_index+1}_#{week_index+1}"
        $courses[key] = {
          professor: session["professor"],
          enrollment: session["capacity"]
        }
      end
    end
  else
    # Single session course
    data["weekly"].times do |week_index|
      key = "#{course_code}_1_#{week_index+1}"  # Only one professor
      $courses[key] = {
        professor: data["professor"],
        enrollment: data["capacity"]
      }
    end
  end
end

pretty = JSON.pretty_generate($courses)
File.write("courses(sorich).json", pretty)
