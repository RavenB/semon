module MessagesHelper
  # returns icon class name for showing the right icon in timeline
  def timeline_icon(message_origin)
    case message_origin
    when "googleplus"
      "google-plus"
    when "youtube"
      "youtube-play"
    else
      message_origin
    end
  end

  # returns the letters for semon to show in timeline instead of a social media brand logo
  def timeline_icon_semon(message_origin)
    if "semon" == message_origin
      "<b>SE</b>M".html_safe
    end
  end

  # returns the id and icon name for sentiment
  def timeline_icon_sentiment(message_sentiment)
    case message_sentiment
    when 1
      "sentiment-1 fa-smile-o"
    when 3
      "sentiment-3 fa-frown-o"
    else
      ""
    end
  end

  # returns a formatted message date in format '10.06.2015'
  def message_date(message_datetime)
    message_datetime.localtime.strftime("%d.%m.%Y")
  end

  # returns a formatted message date in format '10.06.2015'
  def message_time(message_datetime)
    message_datetime.localtime.strftime("%H:%M")
  end

  # returns the message text with detected links formatted to html links
  def message_text_with_links(message_text)
    Rinku.auto_link(CGI.unescape(message_text), :all, "target='_blank'").html_safe
  end

  # returns an image html tag for user image if present
  def message_user_image(message_details)
    if message_details.present? && JSON.parse(message_details)["user"]["image"].present?
      "<img src='#{JSON.parse(message_details)["user"]["image"]}' />".html_safe
    end
  end

  # returns the public user url
  def message_user_url(message_details)
    message_details_json = JSON.parse(message_details)
    if message_details_json["user"]["url"].present?
      message_details_json["user"]["url"]
    else
      "#"
    end
  end

  # returns color class for given rating
  def message_rating_class(message_rating)
    case message_rating
    when 1
      "rating-1"
    when 2
      "rating-2"
    when 3
      "rating-3"
    else
      ""
    end
  end

  # returns the public message url
  # twitter url: M_DETAILS.USER.URL/status/M_DETAILS.ID
  # instagram url: M_DETAILS.LINK
  def message_url(message)
    message_details_json = JSON.parse(message.m_details)
    if "twitter" == message.m_origin && message_details_json["id"].present? &&
       message_details_json["user"]["url"].present?
      "#{message_details_json["user"]["url"]}/status/#{message_details_json["id"]}"
    elsif "instagram" == message.m_origin && message_details_json["link"].present?
      message_details_json["link"]
    else
      "#"
    end
  end

  def escape_text_characters(text_string)
    CGI.escape(text_string).gsub("+", " ")
  end

  def unescape_text_characters(text_string)
    CGI.unescape(text_string)
  end

  # create message.m_details string when creating manually
  def manual_details_json(message_details)
    m_details = {}
    m_details[:id] = message_details[:id]
    m_details[:hashtags] = clear_and_get_hashtags_from_string(message_details[:hashtags])
    m_details[:user] = {}
    m_details[:user][:id] = ""
    m_details[:user][:url] = message_details[:user][:url]
    m_details[:user][:image] = message_details[:user][:image]
    m_details[:manual] = {}
    m_details[:manual][:time] = Time.now.to_f
    m_details.to_json.to_s
  end

  # splits given words removes hashtags and creates array
  def clear_and_get_hashtags_from_string(hashtags_string)
    hashtags_string.gsub(',', ' ').split(' ').map{ |h| h.gsub('#', '') }
  end

  # checks the message sentiment and saves it to the message
  # 1 = positive
  # 2 = neutral
  # 3 = negative
  # the base is an english txt file and a smiley file:
  # https://github.com/7compass/sentimental/blob/master/lib/sentiwords.txt
  # https://github.com/7compass/sentimental/blob/master/lib/sentislang.txt
  # with an own file in addition:
  def analyse_sentiment(message_text)
    # to get an analysed score for the string between -1.0 and 1.0
    score = SentimentModule.score(message_text)
    if score > 0.45
      1
    elsif score < -0.45
      3
    else
      2
    end
  end
end
