# encoding: utf-8

class DashboardController < ApplicationController
  before_action :set_campaign, only: [
                                       :messages_in_period,
                                       :messages_at_time,
                                       :sentiment,
                                       :top_tags,
                                       :word_cloud,
                                       :word_tree,
                                       :top_authors,
                                       :author_genders
                                     ]

  # GET /dashboard/1/messages_in_period
  def messages_in_period
    # [["10.06.2015", 50], ["11.06.2015", 40]]
    @campaign_messages = @campaign.messages.order(m_moment: :asc)
                                           .group_by{ |m| view_context.message_date(m.m_moment)}
                                           .collect{ |date, messages|
                                             [date, messages.count]
                                           }
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
    # [[{v: [14, 30], f: "14:30"}, 50], [{v: [17, 30], f: "17:30"}, 40]]
    @campaign_messages = @campaign.messages.order(m_moment: :asc)
                                           .group_by{ |m|
                                              view_context.message_time(m.m_moment).split(":").first
                                           }.collect{ |time, messages|
                                             [
                                               {
                                                 v: time.split(":").map{ |a| a.to_i },
                                                 f: "#{time}:00"
                                               },
                                               messages.count
                                             ]
                                           }.sort_by{ |a|
                                             a.first[:f]
                                           }
    if @campaign_messages.blank?
      # create empty dummy for campaign start date to prevent google charts errors
      @campaign_messages = [[[0, 0], 0]]
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
                                   }.collect{ |sentiment_id, messages|
                                     case sentiment_id
                                     when 1
                                       ["Positiv", messages.count, "#00a65a"]
                                     when 3
                                       ["Negativ", messages.count, "#dd4b39"]
                                     end
                                   }
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
    @campaign_tags = @campaign.tags.group_by{ |t| t.t_name }.collect{ |t|
      [t.first, t.last.map{ |t| t.t_count }.inject(:+)]
    }.sort_by{ |t| t.last }.reverse.take(top_tags_count.to_i)
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
                              }.collect{ |word, words|
                                [word, words.count] if word.length > 3 # min character length
                              }.compact
                              .sort_by{ |a|
                                a.last
                              }.reverse[1..101] # 100 without first
    # word cloud fails if the range is to big between first and last tag, so try to keep the
    # range under 1000 --> top tags could be excluded (but you see them in other charts)
    while @campaign_words.any? do
      if @campaign_words.first[1] - 600 > @campaign_words.last[1]
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

  # GET /dashboard/1/top_authors
  def top_authors
    # [[{v: "www.twitter.com/author1", f: "author1"}, 10],
    #  [{v: "www.twitter.com/author2", f: "author2"}, 5]]
    @campaign_authors = @campaign.messages.group_by{ |message| message.m_author }
                                          .collect{ |author, messages|
                                            [
                                              {
                                                v: messages.first.m_details,
                                                f: author
                                              },
                                              messages.count,
                                            ]
                                          }.sort_by{ |a|
                                            a.last
                                          }.reverse.take(15)
    respond_to do |format|
      format.json {
        render json: { responseText: @campaign_authors.unshift(["Author", "Beiträge"]).to_json }
      }
    end
  end

  # GET /dashboard/1/author_genders
  def author_genders
    # [["female", 10], ["male", 5]]
    f_count = 0
    m_count = 0
    campaign_genders = @campaign.messages.map(&:m_author).group_by{ |author|
                                           GenderModule.get_gender(author.split(" ").first)
                                         }.map{ |gender, authors|
                                           case gender.to_s
                                           when "female"
                                             f_count += authors.count
                                           when"mostly_female"
                                             f_count += authors.count
                                           when "male"
                                             m_count += authors.count
                                           when "mostly_male"
                                             m_count += authors.count
                                           end
                                         }
                                         p campaign_genders
    @campaign_genders = [
      ["Weiblich", f_count],
      ["Männlich", m_count]
    ]
    respond_to do |format|
      format.json {
        render json: { responseText: @campaign_genders.unshift(["Geschlecht", "Anzahl"]).to_json }
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
      cleaned_message = CGI.unescape(message).gsub(". ", " ").gsub("!", " ").gsub("?", " ")
                           .gsub("_", " ").gsub("-", " ").gsub("+", " ").gsub(": ", " ")
                           .gsub(";", " ").gsub(",", " ").gsub("(", " ").gsub(")", " ")
                           .gsub("rt ", " ").gsub("RT ", " ")
    end
end
