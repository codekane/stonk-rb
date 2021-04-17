class Stonk < ActiveRecord::Base
  validates :symbol, presence: true, uniqueness: true
  has_and_belongs_to_many :searches
  # has_one :count, through: :search
end
