class Board < ActiveRecord::Base
  validates :state, presence: true, length: { :is => 9 }
end
