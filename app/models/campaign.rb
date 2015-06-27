# == Schema Information
#
# Table name: campaigns
#
#  id            :integer          not null, primary key
#  c_name        :string(255)      not null
#  c_description :string(255)
#  c_start       :datetime         not null
#  c_end         :datetime         not null
#  c_status      :integer          default(0), not null
#  last_accessed :datetime
#  created_at    :datetime
#  updated_at    :datetime
#

class Campaign < ActiveRecord::Base
  has_many :messages
  has_many :tags

  validates :c_name, uniqueness: true
  validates :c_name, :c_start, :c_end, presence: true
end
