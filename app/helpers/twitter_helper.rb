module TwitterHelper
  def create_twitter_message(message, tweet)
    message.m_author = tweet.user.name
    message.m_text = escape_text_characters(tweet.text)
    message.m_moment = tweet.created_at
    message.m_origin = "twitter"
    message.m_details = twitter_details_json(message, tweet)
    message.save
  end

  def escape_text_characters(tweet_text)
    CGI.escape(tweet_text).gsub('+', ' ')
  end

  def twitter_details_json(message, tweet)
    twitter_details_json = {}
    twitter_details_json[:id] = tweet.id
    twitter_details_json[:hashtags] = tweet.hashtags.map{ |h| h.text }
    twitter_details_json[:user] = {}
    twitter_details_json[:user][:id] = tweet.user.id
    twitter_details_json[:user][:url] = tweet.user.url.to_s
    # twitter_details_json[:user][:image] = tweet.user.profile_image_url.to_s
    # twitter_details_json[:user][:screen_name] = tweet.user.screen_name
    # twitter_details_json[:user][:location] = tweet.user.location.to_s
    # twitter_details_json[:user][:lang] = tweet.user.lang
    # twitter_details_json[:user][:followers_count] = tweet.user.followers_count
    # twitter_details_json[:user][:statuses_count] = tweet.user.statuses_count
    # twitter_details_json[:user][:friends_count] = tweet.user.friends_count
    twitter_details_json.to_json.to_s
  end
end
