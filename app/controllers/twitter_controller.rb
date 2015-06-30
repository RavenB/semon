class TwitterController < ApplicationController
  before_action :set_client, only: [:tweets]
  before_action :set_campaign, only: [:tweets]

  # get tweets for a campaign
  def tweets
    if @campaign.c_status == 1
      all_campaign_tags = @campaign.tags.map{ |t| "##{t.t_name}" }.join(" OR ")
      from_date = @campaign.c_start.strftime("%Y-%m-%d")
      # to_date + 1 because api wants 10.06.2015 - 13.06.2015 if you request data for 10th, 11th
      # and 12th of june but the campaign end date needs to be included
      to_date = (@campaign.c_end + 1.day).strftime("%Y-%m-%d")
      query = create_query(all_campaign_tags, from_date, to_date)
      get_twitter_data(@client, query)
    end
    respond_to do |format|
      format.js
    end
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

    # returns query for the campaign
    # combining all tags and their conenctions
    def create_query(all_campaign_tags, from_date, to_date)
      "#{all_campaign_tags} since:#{from_date} until:#{to_date}"
    end

    # send request to twitter api
    # returns up to 500 tweets
    def send_request(client, query, max_id, since_id)
      client.search(query, {
        result_type: "recent", lang: "de", max_id: max_id, since_id: since_id
      }).take(500)
    end

    # iterate over twitter response and save messages to database
    # checks last saved message to iterate backwars through twitter data with max_id
    # when done till campaign start, only check new tweets with since_id
    # read for info about max_id/since_id: https://dev.twitter.com/rest/public/timelines
    def get_twitter_data(client, query)
      sorted_twitter_messages_for_campaign = @campaign.messages.twitter.order(m_moment: :desc)
      last_50_campaign_messages = sorted_twitter_messages_for_campaign.last(50)
      first_50_campaign_messages = sorted_twitter_messages_for_campaign.first(50)
      max_id = nil
      since_id = nil
      if @campaign.last_accessed.blank? && last_50_campaign_messages.present?
        max_id = current_oldest_message_tweet_id(last_50_campaign_messages, -1)
      elsif first_50_campaign_messages.present?
        since_id = current_latest_message_tweet_id(first_50_campaign_messages, 0)
      end
      search_results = send_request(client, query, max_id, since_id)
      if (since_id.blank? && search_results.count > 1) || (since_id.present? && search_results.any?)
        iterate_message_save(search_results, 0, 99)
        @return_info = "#{search_results.count} msgs | max_id: #{max_id} | since_id: #{since_id}"
      else
        @campaign.last_accessed = Time.now
        @campaign.save
        @return_info = "#{search_results.count} msg(s) | max_id: #{max_id} | since_id: #{since_id}"
      end
    end

    # counter represents count from behind to get the oldest message
    # iterate forwards if last has no tweet id
    # @array[-1..-1] returns array with last message, @array[-2..-2] returns next to last and so on
    def current_oldest_message_tweet_id(last_50_campaign_messages, counter)
      last_message = last_50_campaign_messages[counter..counter].first
      last_message_details_json = JSON.parse(last_message.m_details)
      if last_message_details_json.present? && last_message_details_json["id"].present?
        return last_message_details_json["id"]
      else
        current_oldest_message_tweet_id(counter - 1)
      end
    end

    # counter represents count to get the latest message
    # iterate backwards if latest has no tweet id
    # @array[0..0] returns array with first message, @array[1..1] returns second and so on
    def current_latest_message_tweet_id(first_50_campaign_messages, counter)
      first_message = first_50_campaign_messages[counter..counter].first
      first_message_details_json = JSON.parse(first_message.m_details)
      if first_message_details_json.present? && first_message_details_json["id"].present?
        return first_message_details_json["id"]
      else
        current_latest_message_tweet_id(counter + 1)
      end
    end

    # iterate the saving of message from the maximum of 500 responses to have faster server actions
    # save in 100 parts
    def iterate_message_save(search_results, counter_from, counter_to)
      search_results_part = search_results[counter_from..counter_to]
      if search_results_part.present?
        search_results_part.each do |tweet|
          message = Message.new(campaign_id: @campaign.id)
          view_context.create_twitter_message(message, tweet)
          message.save
        end
        iterate_message_save(search_results, counter_from + 100, counter_to + 100)
      end
    end
end

# https://dev.twitter.com/rest/public/search
# https://dev.twitter.com/rest/reference/get/search/tweets
