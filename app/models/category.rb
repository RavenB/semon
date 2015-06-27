# == Schema Information
#
# Table name: categories
#
#  id              :integer          not null, primary key
#  cat_name        :string(255)      not null
#  cat_description :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

class Category < ActiveRecord::Base
  has_many :messages

  validates :cat_name, presence: true
end
