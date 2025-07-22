class Student < ApplicationRecord
  has_many :lessons, dependent: :destroy
  has_many :charts
  has_many :figures, through: :charts
  belongs_to :user, optional: true

  def full_name
    return self.first_name + " " + self.last_name
  end
end
