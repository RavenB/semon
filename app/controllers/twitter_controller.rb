class TwitterController < ApplicationController
  before_action :set_client, only: [:tweets]
  before_action :set_campaign, only: [:tweets]

  # get tweets for a campaign
  def tweets
    @last_saved_tweet_id = 0
    if @campaign.c_status == 1
      @last_saved_tweet_id = get_twitter_data(@client, create_query(nil), false)
    end
    respond_to do |format|
      format.json
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
    # creating array with elements at a maximum string size of 500 (twitter api limit)
    # https://dev.twitter.com/rest/reference/get/search/tweets
    def create_query(last_access)
      query_array = []
      if last_access.present?
        all_campaign_tags = @campaign.tags.where("created_at > ?", last_access)
      else
        all_campaign_tags = @campaign.tags
      end
      processed_tags = [] # should always < 491 length
      all_campaign_tags.roots.each do |tag_root|
        all_tags_from_root = tag_root.subtree
        all_tags_from_root.each do |tag|
          if tag.t_connection.present?
            connected_tag = Tag.find(tag.t_connection)
            processed_tags << "#{tag.t_name} #{connected_tag.t_name}"
          else
            processed_tags << tag.t_name
          end
          # count depends on escaped url param string for query
          if CGI.escape(build_query_with_dates(processed_tags)).length > 490
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
    def get_twitter_data(client, query_array, recrawl)
      # fresh first request for tweets with nil, nil
      max_id = nil
      since_id = nil
      if @campaign.messages.twitter.present?
        if @campaign.last_accessed.blank?
          # request for tweets in the past after a last_accessed reset
          max_id = current_oldest_message_tweet_id(-1)
        else
          if !recrawl
            # request for new tweets since last message
            since_id = current_latest_message_tweet_id(0)
          else
            # request for tweets in the past (with new tags) and nil ids again
          end
        end
      end
      # Thread.new do
        last_saved_tweet_id = 0
        if @campaign.last_accessed.present? && !recrawl
          if @campaign.tags.last.created_at > @campaign.last_accessed
            # save last access time
            last_access = @campaign.last_accessed
            # mark access and recrawl with new tags
            @campaign.last_accessed = Time.now.utc
            @campaign.save
            last_saved_tweet_id = get_twitter_data(client, create_query(last_access), true)
          end
        else
          query_array.each do |query|
            last_saved_tweet_id = iterate_twitter_request(client, query, max_id, since_id)
          end
          # mark access to finish requesting past tweets
          @campaign.last_accessed = Time.now.utc
          @campaign.save
        end
      # end
      last_saved_tweet_id
    end

    # TODO: iterate correctly
    def iterate_twitter_request(client, query, max_id, since_id)
      search_results = send_request(client, query, max_id, since_id)
      if max_id.blank? && since_id.blank? && search_results.count > 1
        last_saved_tweet_id = iterate_message_save(search_results, 0, 499, "default")
        max_id = last_saved_tweet_id
        if max_id > 0
          last_saved_tweet_id = iterate_twitter_request(client, query, max_id, since_id)
        else
          last_saved_tweet_id = 0
        end
      elsif max_id.present? && search_results.count > 1
        last_saved_tweet_id = iterate_message_save(search_results, 0, 499, "default")
        if last_saved_tweet_id.present? && max_id != last_saved_tweet_id
          max_id = last_saved_tweet_id
        end
        if max_id > 0
          last_saved_tweet_id = iterate_twitter_request(client, query, max_id, since_id)
        else
          last_saved_tweet_id = 0
        end
      elsif max_id.blank? && since_id.present? && search_results.any?
        last_saved_tweet_id = iterate_message_save(search_results, 0, 499, "reverse")
        if last_saved_tweet_id.present? && since_id != last_saved_tweet_id
          since_id = last_saved_tweet_id
        end
        if since_id > 0
          last_saved_tweet_id = iterate_twitter_request(client, query, max_id, since_id)
        else
          last_saved_tweet_id 0
        end
      else
        last_saved_tweet_id = 0
      end
      last_saved_tweet_id
    end

    # counter represents count from behind to get the oldest message with details id (twitter id)
    # iterate forwards if last has no tweet id
    # @array[-1..-1] returns array with last message, @array[-2..-2] returns next to last and so on
    def current_oldest_message_tweet_id(counter)
      sorted_twitter_messages_for_campaign = @campaign.messages.twitter.order(m_moment: :desc)
      last_message = sorted_twitter_messages_for_campaign[counter..counter].first
      last_message_details_json = JSON.parse(last_message.m_details)
      if last_message_details_json.present? && last_message_details_json["id"].present?
        last_message_details_json["id"]
      else
        current_oldest_message_tweet_id(counter - 1)
      end
    end

    # counter represents count to get the latest message with details id (twitter id)
    # iterate backwards if latest has no tweet id
    # @array[0..0] returns array with first message, @array[1..1] returns second and so on
    def current_latest_message_tweet_id(counter)
      sorted_twitter_messages_for_campaign = @campaign.messages.twitter.order(m_moment: :desc)
      first_message = sorted_twitter_messages_for_campaign[counter..counter].first
      first_message_details_json = JSON.parse(first_message.m_details)
      if first_message_details_json.present? && first_message_details_json["id"].present?
        first_message_details_json["id"]
      else
        current_latest_message_tweet_id(counter + 1)
      end
    end

    # TODO: iterate correctly
    # iterate the saving of message from the maximum of 500 responses to have faster server actions
    # save in 100 parts
    # returns last saved tweet id
    def iterate_message_save(search_results, counter_from, counter_to, direction)
      search_results_part = search_results[counter_from..counter_to]
      if search_results_part.present?
        if "reverse" == direction
          search_results_part.reverse
        end
        last_tweet_id = 0
        search_results_part.each do |tweet|
          message = Message.new(campaign_id: @campaign.id)
          message = view_context.create_twitter_message(message, tweet)
          if dismiss_accounts(message)
            if message.save
              last_tweet_id = tweet.id
            end
          end
        end
        # iterate_message_save(search_results, counter_from + 100, counter_to + 100, last_tweet_id)
      else
        last_tweet_id = 0
      end
      last_tweet_id
    end

    def dismiss_accounts(message)
      case message.m_author
      when "trendingdeutsch"
        false
      when "trendinggermany"
        false
      when "trendiede"
        false
      when "javatheghost"
        false
      when "tweettrendfacts"
        false
      else
        true
      end
    end
end

# https://dev.twitter.com/rest/public/search
# https://dev.twitter.com/rest/reference/get/search/tweets
