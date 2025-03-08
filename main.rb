require 'json'

professors = {}
courses = Hash.new(0)
lines = File.readlines('courses.txt').map(&:chomp)

#lines.each_with_index do |line, index|    start with prof first in file to work
#  professors[line] = true if index % 5 == 0
#end

lines.each_with_index do |line, index|
  courses[line] += 1 if index % 5 == 0
end

pretty = JSON.pretty_generate(courses)

File.write("courses.json", pretty)

