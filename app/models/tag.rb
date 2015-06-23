# == Schema Information
#
# Table name: tags
#
#  id           :integer          not null, primary key
#  t_name       :string(255)      not null
#  ancestry     :string(255)
#  t_count      :integer          default(0), not null
#  t_connection :string(255)
#  campaign_id  :integer          not null
#  created_at   :datetime
#  updated_at   :datetime
#

class Tag < ActiveRecord::Base
  has_many :messages, through: :message_tags
  has_many :message_tags

  belongs_to :campaign

  has_ancestry orphan_strategy: :restrict
end
