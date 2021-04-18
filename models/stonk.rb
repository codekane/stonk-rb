class Stonk < ActiveRecord::Base
  validates :symbol, presence: true, uniqueness: true
  has_many :search_stonks
  has_many :searches, through: :search_stonks
end

class SearchStonk < ActiveRecord::Base
  belongs_to :stonk
  belongs_to :search
end

class Search < ActiveRecord::Base
  has_many :search_stonks
  has_many :stonks, through: :search_stonks
end
