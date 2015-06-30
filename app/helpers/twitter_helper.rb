module TwitterHelper
  def create_twitter_message(message, tweet)
    message.m_author = tweet.user.name
    message.m_text = escape_text_characters(tweet.text)
    message.m_moment = tweet.created_at
    message.m_origin = "twitter"
    message.m_details = twitter_details_json(message, tweet)
    message.sentiment_id = analyse_sentiment(tweet.text)
  end

  # create message.m_details string when getting from api
  def twitter_details_json(message, tweet)
    twitter_details = {}
    twitter_details[:id] = tweet.id
    twitter_details[:hashtags] = tweet.hashtags.map{ |h| h.text }
    twitter_details[:user] = {}
    twitter_details[:user][:id] = tweet.user.id
    twitter_details[:user][:url] = tweet.user.url.to_s
    twitter_details[:user][:image] = tweet.user.profile_image_url.to_s
    # twitter_details[:user][:screen_name] = tweet.user.screen_name
    # twitter_details[:user][:location] = tweet.user.location.to_s
    # twitter_details[:user][:lang] = tweet.user.lang
    # twitter_details[:user][:followers_count] = tweet.user.followers_count
    # twitter_details[:user][:statuses_count] = tweet.user.statuses_count
    # twitter_details[:user][:friends_count] = tweet.user.friends_count
    twitter_details.to_json.to_s
  end

  # create message.m_details string when creating manually
  def manual_details_json(message_details)
    twitter_details = {}
    twitter_details[:id] = message_details[:id]
    twitter_details[:hashtags] = clear_and_get_hashtags_from_string(message_details[:hashtags])
    twitter_details[:user] = {}
    twitter_details[:user][:id] = ""
    twitter_details[:user][:url] = message_details[:user][:url]
    twitter_details[:user][:image] = message_details[:user][:image]
    twitter_details.to_json.to_s
  end

  # splits given words removes hashtags and creates array
  def clear_and_get_hashtags_from_string(hashtags_string)
    hashtags_string.gsub(',', ' ').split(' ').map{ |h| h.gsub('#', '') }
  end
end
