# Platform

A project to create an online platform for booking dance classes and keeping track of student progress.


    Teacher
last_name:string
first_name:string
email:string
phone:string

    Student
last_name:string
first_name:string
phone:string
email:string

    Class
has_one:teacher
has_many:students
start_date:datetime
duration:float
max_attendance:int
min_attendance:int
booking_deadline:datetime

    Program



