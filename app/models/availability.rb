class Availability < ApplicationRecord
  belongs_to :available_for, polymorphic: true
end
