class Figure < ApplicationRecord
  has_many :charts
  has_many :students, through: :charts
end
