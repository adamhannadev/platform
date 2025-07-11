class Student < ApplicationRecord
    has_many :lessons, dependent: :destroy
end
