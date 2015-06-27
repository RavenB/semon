class TwitterController < ApplicationController
  before_action :set_client, only: [:tweets]
  before_action :set_campaign, only: [:tweets]

  # get tweets for a campaign
  def tweets
    all_campaign_tags = @campaign.tags.map{ |t| "##{t.t_name}" }.join(" OR ")
    from_date = @campaign.c_start.strftime("%Y-%m-%d")
    to_date = (@campaign.c_end + 1.day).strftime("%Y-%m-%d")
    query = "#{all_campaign_tags} since:#{from_date} until:#{to_date}"

    search_results = @client.search(query, { result_type: "recent", count: 50, lang: "de" })
                            .take(50)

    search_results.each do |tweet|
      message = Message.new(campaign_id: @campaign.id)
      view_context.create_twitter_message(message, tweet)
    end

    redirect_to campaign_path(@campaign)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_client
      @client = Twitter::REST::Client.new do |config|
        config.consumer_key        = Rails.application.secrets.twitter["consumer_key"]
        config.consumer_secret     = Rails.application.secrets.twitter["consumer_secret"]
        config.access_token        = Rails.application.secrets.twitter["access_token"]
        config.access_token_secret = Rails.application.secrets.twitter["access_token_secret"]
      end
    end

    def set_campaign
      @campaign = Campaign.find(params[:id])
    end
end

# https://dev.twitter.com/rest/public/search
# https://dev.twitter.com/rest/reference/get/search/tweets
