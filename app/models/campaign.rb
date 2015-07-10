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

  before_save :set_end_date_minutes

  scope :active, -> { where(c_status: 1) }
  scope :inactive, -> { where(c_status: 0) }

  private
    def set_end_date_minutes
      self.c_end = self.c_end + 23.hours + 59.minutes + 59.seconds
    end
end
