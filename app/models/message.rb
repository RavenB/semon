# == Schema Information
#
# Table name: messages
#
#  id           :integer          not null, primary key
#  m_author     :string(255)      not null
#  m_text       :text             not null
#  m_moment     :datetime         not null
#  m_origin     :string(255)      not null
#  m_details    :text
#  m_rating     :integer
#  campaign_id  :integer          not null
#  category_id  :integer
#  sentiment_id :integer
#  created_at   :datetime
#  updated_at   :datetime
#

class Message < ActiveRecord::Base
  has_many :tags, through: :message_tags
  has_many :message_tags

  belongs_to :campaign
  belongs_to :category
  belongs_to :sentiment

  validates :m_author, :m_text, :m_moment, :m_origin, :campaign_id, presence: true
end
