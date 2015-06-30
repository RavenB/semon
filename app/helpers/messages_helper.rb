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

  # returns a formatted message date in format '10.06.2015'
  def message_date(message_datetime)
    message_datetime.strftime("%d.%m.%Y")
  end

  # returns a formatted message date in format '10.06.2015'
  def message_time(message_datetime)
    message_datetime.strftime("%H:%M")
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

  # returns the public twitter user url
  def message_user_url(message_details)
    message_details_json = JSON.parse(message_details)
    if message_details.present? && message_details_json["user"]["url"].present?
      message_details_json["user"]["url"]
    end
  end

  # returns the public tweet url: M_DETAILS.USER.URL/status/M_DETAILS.ID
  def message_tweet_url(message_details)
    message_details_json = JSON.parse(message_details)
    if message_details.present? && message_details_json["id"].present? &&
       message_details_json["user"]["url"].present?
      "#{message_details_json["user"]["url"]}/status/#{message_details_json["id"]}"
    end
  end

  # checks the message sentiment and saves it to the message
  # 1 = positive
  # 2 = neutral
  # 3 = negative
  # the base is an english txt file and a smiley file:
  # https://github.com/7compass/sentimental/blob/master/lib/sentiwords.txt
  # https://github.com/7compass/sentimental/blob/master/lib/sentislang.txt
  # with an own file in addition:
  def analyse_sentiment

  end
end
