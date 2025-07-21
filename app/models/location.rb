class Location < ApplicationRecord
  has_many :availabilities, as: :available_for
end
