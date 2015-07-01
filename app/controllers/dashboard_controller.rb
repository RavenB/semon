class DashboardController < ApplicationController
  before_action :set_campaign, only: [
                                       :messages_in_period,
                                       :top_15_tags,
                                       :sentiment
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

  # GET /dashboard/1/top_15_tags
  def top_15_tags
    # [["tag1", 10], ["tag2", 5]]
    @campaign_tags = @campaign.tags.order(t_count: :desc).take(15).collect do |tag|
      [tag.t_name, tag.t_count]
    end
    respond_to do |format|
      format.json {
        render json: { responseText: @campaign_tags.unshift(["Stichwort", "Anzahl"]).to_json }
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_campaign
      @campaign = Campaign.find(params[:id])
    end
end
