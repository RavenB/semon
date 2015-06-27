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
end
