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
  validates :m_details, uniqueness: true

  after_create :set_message_tags

  private
    # check message text for campaign tags and save matched tags to the message
    def set_message_tags
      campaign = Campaign.find(self.campaign_id)
      campaign_tags = campaign.tags.map{ |t| t.t_name.downcase }.uniq
      message_words = clean_up_message(CGI.unescape(self.m_text)).split(' ').uniq
      message_tags = campaign_tags & message_words
      message_tags.each do |tag|
        current_tag = campaign.tags.where(t_name: tag).first
        MessageTag.create(message_id: self.id, tag_id: current_tag.id)
        current_tag.increment!(:t_count)
      end
    end

    # clean up messages to got all words without punctuation marks, hashtags, @s, ...
    def clean_up_message(message)
      message.downcase.gsub('#', ' ').gsub('@', ' ').gsub('.', ' ').gsub('!', ' ').gsub('?', ' ')
                      .gsub('-', ' ').gsub('+', ' ').gsub(':', ' ').gsub(',', ' ').gsub(';', ' ')
    end
end
