require 'json'


json_string = File.read('courses(duration).json')  
parsed = JSON.parse(json_string)         


$courses_duration = parsed.transform_values do |course|
  {
    professor:  course["professor"],
    enrollment: course["enrollment"],
    duration:   course["duration"]
  }
end
