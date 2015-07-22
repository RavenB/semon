class TwitterController < ApplicationController
  before_action :set_campaign, only: [:tweets]

  # get tweets for a campaign
  def tweets
    old_tweets_count = @campaign.messages.twitter.count
    get_twitter_data(get_client, create_query, since)
    @newly_saved_tweets = @campaign.messages.twitter.count - old_tweets_count
    respond_to do |format|
      format.json
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_campaign
      @campaign = Campaign.find(params[:id])
    end

    def get_client
      Twitter::REST::Client.new do |config|
        config.consumer_key        = Rails.application.secrets.twitter["consumer_key"]
        config.consumer_secret     = Rails.application.secrets.twitter["consumer_secret"]
        config.access_token        = Rails.application.secrets.twitter["access_token"]
        config.access_token_secret = Rails.application.secrets.twitter["access_token_secret"]
      end
    end

    # returns query for the campaign
    # combining all tags and their connections
    # creating array with elements at a maximum string size of nearly 500 (twitter api limit 500)
    # https://dev.twitter.com/rest/reference/get/search/tweets
    def create_query
      query_array = []
      all_campaign_tags = @campaign.tags
      processed_tags = [] # should always < 471 length
      all_campaign_tags.roots.each do |tag_root|
        processed_tags << tag_root.t_name
        all_tags_from_root = tag_root.descendants
        all_tags_from_root.each do |tag|
          if tag.t_connection.present?
            connected_tag = Tag.find(tag.t_connection)
            processed_tags << "#{tag.t_name} #{connected_tag.t_name}"
          else
            processed_tags << tag.t_name
          end
          # count depends on escaped url param string for query
          if CGI.escape(build_query_with_dates(processed_tags)).length > 470
            next_first_element = processed_tags.pop
            query_array << build_query_with_dates(processed_tags)
            processed_tags = [next_first_element]
          end
        end
      end
      if processed_tags.any?
        query_array << build_query_with_dates(processed_tags)
      end
      query_array
    end

    def build_query_with_dates(processed_tags)
      from_date = @campaign.c_start.strftime("%Y-%m-%d")
      # to_date + 1 because api wants 10.06.2015 - 13.06.2015 if you request data for 10th, 11th
      # and 12th of june but the campaign end date needs to be included
      to_date = (@campaign.c_end + 1.day).strftime("%Y-%m-%d")
      query = [
        "#{processed_tags.map{ |t| t.downcase }.join(' OR ')}",
        "since:#{from_date}", "until:#{to_date}"
      ].join(" ")
      query
    end

    # gets the latest tweet id
    # counter represents count to get the latest message with details id (twitter id)
    # iterate backwards if latest has no tweet id
    # @array[0..0] returns array with first message, @array[1..1] returns second and so on
    def since(counter = 0)
      since_id = 0
      if @campaign.last_accessed.present?
        sorted_twitter_messages_for_campaign = @campaign.messages.twitter.order(m_moment: :desc)
        first_message = sorted_twitter_messages_for_campaign[counter..counter].first
        if first_message.present?
          first_message_details_json = JSON.parse(first_message.m_details)
          if first_message_details_json.present? && first_message_details_json["id"].present?
            since_id = first_message_details_json["id"]
          else
            since_id = since(counter + 1)
          end
        end
      end
      since_id
    end

    # send request to twitter search api
    # returns up to 500 tweets
    def send_request(client, query, since_id)
      begin
        logger.debug " "
        logger.debug "query: "
        logger.debug " "
        logger.debug query
        client.search(query, {
          result_type: "recent", lang: "de", since_id: since_id, count: 100
        }).take(500)
      rescue => e
        logger.error " "
        logger.error "Error:"
        logger.error " "
        logger.error e.message
        []
      end
    end

    # read for info about max_id/since_id: https://dev.twitter.com/rest/public/timelines
    def get_twitter_data(client, query_array, since_id)
      query_array.each do |query|
        search_results = send_request(client, query, since_id)
        search_results.each do |tweet|
          message = Message.new(campaign_id: @campaign.id)
          message = view_context.create_twitter_message(message, tweet)
          if valid_accounts(tweet)
            message.save
          end
        end
      end
      # update campaigns last access
      @campaign.last_accessed = Time.now.utc
      @campaign.save
    end

    def valid_accounts(tweet)
      if tweet.user.url.to_s.include?("trendingdeutsch")
        false
      elsif tweet.user.url.to_s.include?("trendinggermany")
        false
      elsif tweet.user.url.to_s.include?("trendiede")
        false
      elsif tweet.user.url.to_s.include?("javatheghost")
        false
      elsif tweet.user.url.to_s.include?("tweettrendfacts")
        false
      elsif tweet.user.url.to_s.include?("trendsberlin")
        false
      else
        true
      end
    end
end
