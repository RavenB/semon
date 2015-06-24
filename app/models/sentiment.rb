# == Schema Information
#
# Table name: sentiments
#
#  id         :integer          not null, primary key
#  s_name     :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#

class Sentiment < ActiveRecord::Base
  attr_accessible :s_name

  has_many :messages

  validates :s_name, presence: true
end
