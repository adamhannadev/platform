class Teacher < ApplicationRecord
    has_many :lessons, dependent: :destroy
end
