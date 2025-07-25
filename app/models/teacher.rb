class Teacher < ApplicationRecord
    has_many :lessons, dependent: :destroy
    has_many :availabilities, as: :available_for
    belongs_to :user, optional: true

    accepts_nested_attributes_for :user

    def full_name
        return self.first_name + " " + self.last_name
    end
end
