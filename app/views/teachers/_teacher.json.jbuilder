json.extract! teacher, :id, :last_name, :first_name, :phone, :email, :created_at, :updated_at
json.url teacher_url(teacher, format: :json)
