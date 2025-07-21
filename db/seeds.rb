# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create Teachers
teacher1 = Teacher.create!(first_name: "Adam", last_name: "Hanna", email: "info@adamhannaballroom.com", phone: "250-480-9246")
teacher2 = Teacher.create!(first_name: "Tyna", last_name: "Kottova", email: "tyna@adamhannaballroom.com", phone: "250-555-5555")

# Create Students
student1 = Student.create!(first_name: "Kami", last_name: "Norman", email: "adam.s.hanna@gmail.com", phone: "250-555-55555")
student2 = Student.create!(first_name: "Linda", last_name: "Gould", email: "adamhannadev@gmail.com", phone: "250-555-5555")

# Create Lessons
Lesson.create!(start_time: DateTime.now + 1.day, student: student1, teacher: teacher1, plan: "Intro lesson")
Lesson.create!(start_time: DateTime.now + 2.days, student: student2, teacher: teacher2, plan: "Advanced lesson")

# Create Locations
Location.create!(name: "Trinity", address: "2964 Tillicum Rd.", rate: 9.00)
Location.create!(name: "St. Lukes", address: "52349 Luke Ave.", rate: 65.53)