class Teacher < ApplicationRecord
    has_many :lessons, dependent: :destroy
    has_many :availabilities, as: :available_for
    belongs_to :user, optional: true

    def full_name
        return self.first_name + " " + self.last_name
    end
end
