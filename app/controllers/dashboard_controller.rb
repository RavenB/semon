class DashboardController < ApplicationController
  before_action :set_campaign, only: [
                                       :messages_in_period,
                                       :messages_at_time,
                                       :sentiment,
                                       :top_tags,
                                       :word_cloud,
                                       :word_tree
                                     ]

  # GET /dashboard/1/messages_in_period
  def messages_in_period
    # [["10.06.2015", 50], ["11.06.2015", 40]]
    @campaign_messages = @campaign.messages.order(m_moment: :asc)
                                           .group_by{ |m| view_context.message_date(m.m_moment)}
                                           .collect do |date, messages|
                                             [date, messages.count]
                                           end
    if @campaign_messages.blank?
      # create empty dummy for campaign start date to prevent google charts errors
      @campaign_messages = [[@campaign.c_start.strftime("%d.%m.%Y"), 0]]
    end
    respond_to do |format|
      format.json {
        render json: { responseText: @campaign_messages.unshift(["Datum", "Anzahl"]).to_json }
      }
    end
  end

  # GET /dashboard/1/messages_at_time
  def messages_at_time
    # [["14:30", 50], ["16:23", 40]]
    @campaign_messages = @campaign.messages.order(m_moment: :asc)
                                           .group_by{ |m| view_context.message_time(m.m_moment) }
                                           .collect do |time, messages|
                                             [time, messages.count]
                                           end
    if @campaign_messages.blank?
      # create empty dummy for campaign start date to prevent google charts errors
      @campaign_messages = [[@campaign.c_start.strftime("%H:%M"), 0]]
    end
    respond_to do |format|
      format.json {
        render json: { responseText: @campaign_messages.unshift(["Datum", "Anzahl"]).to_json }
      }
    end
  end

  # GET /dashboard/1/sentiment
  def sentiment
    # [["positive", 10], ["negative", 5]]
    @campaign_sentiment = @campaign.messages.where("sentiment_id = 1 OR sentiment_id = 3")
                                   .group_by{
                                     |m| m.sentiment_id
                                   }.collect do |sentiment_id, messages|
                                     case sentiment_id
                                     when 1
                                       ["Positiv", messages.count, "#00a65a"]
                                     when 3
                                       ["Negativ", messages.count, "#dd4b39"]
                                     end
                                   end
    if @campaign_sentiment.blank?
      # create empty dummy to prevent google charts errors
      @campaign_sentiment = [["Positiv", 0, "#00a65a"], ["Negativ", 0, "#dd4b39"]]
    end
    respond_to do |format|
      format.json {
        render json: {
          responseText: @campaign_sentiment.unshift(["Sentiment", "Anzahl", { role: "style" }])
                                           .to_json
        }
      }
    end
  end

  # GET /dashboard/1/top_tags
  def top_tags
    # [["tag1", 10], ["tag2", 5]]
    top_tags_count = 15
    if params[:top_tags_count].present?
      top_tags_count = params[:top_tags_count]
    end
    @campaign_tags = @campaign.tags.order(t_count: :desc).take(top_tags_count).collect do |tag|
      [tag.t_name, tag.t_count]
    end
    respond_to do |format|
      format.json {
        render json: { responseText: @campaign_tags.unshift(["Stichwort", "Anzahl"]).to_json }
      }
    end
  end

  # GET /dashboard/1/word_cloud
  def word_cloud
    # [["word1", 10], ["word2", 5]]
    @campaign_words = @campaign.messages.map(&:m_text)
                              .collect{ |text|
                                clean_up_message(text).split(" ")
                              }.flatten.group_by{ |word|
                                word.downcase
                              }.collect { |word, words|
                                [word, words.count] if word.length > 3
                              }.compact
                              .sort_by{ |a|
                                a.last
                              }.reverse.take(100)
    # word cloud fails if the range is to big between first and last tag, so try to keep the
    # range under 1000 --> top tags could be excluded (but you see them in other charts)
    while @campaign_words.any? do
      if @campaign_words.first[1] - 1000 > @campaign_words.last[1]
        @campaign_words.shift
      else
        break
      end
    end
    respond_to do |format|
      format.json {
        render json: { responseText: @campaign_words.to_json }
      }
    end
  end

  # GET /dashboard/1/word_tree
  def word_tree
    # [["text1"], ["text2"]]
    @campaign_texts = @campaign.messages.map{ |message|
                                          clean_up_message(message.m_text)
                                        }.collect{ |text| [text] }
    respond_to do |format|
      format.json {
        render json: { responseText: @campaign_texts.unshift(["Beiträge"]).to_json }
      }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_campaign
      @campaign = Campaign.find(params[:id])
    end

    # clean up messages to got all words without punctuation marks, hashtags, @s, ...
    def clean_up_message(message)
      CGI.unescape(message).gsub(". ", " ").gsub("!", " ").gsub("?", " ").gsub("_", " ")
                           .gsub("-", " ").gsub("+", " ").gsub(": ", " ").gsub(";", " ")
                           .gsub(",", " ").gsub("(", " ").gsub(")", " ").gsub("rt ", " ")
                           .gsub("RT ", " ")

    end
end
