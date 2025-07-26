# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create an admin user if it doesn't exist
admin_user = User.find_or_create_by!(email: "admin@example.com") do |user|
  user.password = "password123"
  user.password_confirmation = "password123"
  user.role = "admin"
end

puts "Admin user created: #{admin_user.email} (#{admin_user.role})"

require 'roo'

# Create Figures
sm = Roo::Spreadsheet.open('br_smooth.xlsx')
puts "The sheets are: #{sm.sheets}"
sm.each_with_pagename do |name, sheet|
    puts "#{name}"
    sm.each_row_streaming(offset: 0) do |row|
    Figure.create!(
    name: row[2]&.cell_value,
    dance: name,
    number: row[1]&.cell_value,
    bars: row[3]&.cell_value,
    components: row[4]&.cell_value,
    core: row[0]&.cell_value,
    level: row[5]&.cell_value
    )
    end
end

# Create Students
st = Roo::Spreadsheet.open('student_list.xlsx')
    st.each_row_streaming(offset: 0) do |row|
        Student.find_or_create_by!(email: row[2].cell_value) do |s|
            s.first_name = row[0].cell_value
            s.last_name = row[1].cell_value
            s.email = row[2]&.cell_value
            s.phone = row[3]&.cell_value
        end
    end


user1 = User.create!(email: "adamhannadev@gmail.com", password: "password", role: "Teacher")
user2 = User.create!(email: "adamhannadance@gmail.com", password: "password", role: "Student")

# Create Teachers
teacher1 = Teacher.create!(first_name: "Adam", last_name: "Hanna", email: "adamhannadev@gmail.com", phone: "250-480-9246", user: user1)
teacher2 = Teacher.create!(first_name: "Tyna", last_name: "Kottova", email: "adam.s.hanna@gmail.com", phone: "250-555-5555")

# Assign a user to a student
s1 = Student.third.user = user2
s1.save!

# Create Locations
location1 = Location.create!(name: "Trinity", address: "2964 Tillicum Rd.", rate: 9.00)
location2 = Location.create!(name: "St. Lukes", address: "52349 Luke Ave.", rate: 65.53)

# Enroll a student
Student.first.figures = Figure.where(dance: "Waltz")