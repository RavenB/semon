module InstagramHelper
  def create_instagram_message(message, instagram)
    message.m_author = escape_text_characters(instagram.user.full_name)
    message.m_text = escape_text_characters(instagram.caption.text) if instagram.caption.present?
    message.m_moment = Time.at(instagram.created_time.to_i)
    message.m_origin = "instagram"
    message.m_details = instagram_details_json(message, instagram)
    message.sentiment_id = analyse_sentiment(instagram.caption.text) if instagram.caption.present?
    message
  end

  # create message.m_details string when getting from api
  def instagram_details_json(message, instagram)
    instagram_details = {}
    instagram_details[:id] = instagram.id
    instagram_details[:hashtags] = instagram.tags.map{ |h| escape_text_characters(h) }
    instagram_details[:user] = {}
    instagram_details[:user][:id] = instagram.user.id
    instagram_details[:user][:url] = "http://instagram.com/#{instagram.user.username}"
    instagram_details[:user][:image] = instagram.user.profile_picture
    instagram_details[:link] = instagram.link
    instagram_details.to_json.to_s
  end
end
