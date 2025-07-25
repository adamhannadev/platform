class Student < ApplicationRecord
  has_many :lessons, dependent: :destroy
  has_many :charts
  has_many :figures, through: :charts
  belongs_to :user, optional: true

  accepts_nested_attributes_for :user

  def full_name
    "#{first_name} #{last_name}".strip
  end
end
