# == Schema Information
#
# Table name: message_tags
#
#  id         :integer          not null, primary key
#  message_id :integer          not null
#  tag_id     :integer          not null
#  created_at :datetime
#  updated_at :datetime
#

class MessageTag < ActiveRecord::Base
  attr_accessible :message_id, :tag_id

  belongs_to :message
  belongs_to :tag
end
