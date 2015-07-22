class InstagramController < ApplicationController
  before_action :set_campaign, only: [:instagrams]

  # get instagrams for a campaign
  def instagrams
    old_instagrams_count = @campaign.messages.instagram.count
    get_instagram_data(get_client, create_query, since)
    @newly_saved_instagrams = @campaign.messages.instagram.count - old_instagrams_count
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
      Instagram.configure do |config|
        config.client_id = Rails.application.secrets.instagram["client_id"]
        config.client_secret = Rails.application.secrets.instagram["client_secret"]
      end
      Instagram.client(access_token: session[:access_token])
    end

    # returns query for the campaign
    # creating array with all elements without connection
    # because instagram can only search for one tag at a time
    def create_query
      query_array = []
      @campaign.tags.where(t_connection: nil).each do |tag|
        query_array << CGI.escape(tag.t_name)
      end
      query_array
    end

    # gets the latest instagram id
    # counter represents count to get the latest message with details id (instagram id)
    # iterates to the next element if latest has no instagram id
    # @array[0..0] returns array with first message, @array[1..1] returns second and so on
    def since(counter = 0)
      since_id = "0"
      if @campaign.last_accessed.present?
        sorted_instagram_messages_for_campaign = @campaign.messages.instagram.order(m_moment: :desc)
        first_message = sorted_instagram_messages_for_campaign[counter..counter].first
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

    # send request to instagram api
    def send_request(client, query, options)
      begin
        logger.debug " "
        logger.debug "query: "
        logger.debug " "
        logger.debug query
        client.tag_recent_media(query, options)
      rescue => e
        logger.error " "
        logger.error "Error:"
        logger.error " "
        logger.error e.message
        []
      end
    end

    def get_instagram_data(client, query_array, max_id)
      options = {}
      if max_id != "0"
        options[:max_id] = max_id
      end
      query_array.each do |query|
        search_results = send_request(client, query, options)
        search_results.each do |instagram|
          message = Message.new(campaign_id: @campaign.id)
          message = view_context.create_instagram_message(message, instagram)
          if valid_date(message)
            message.save
          end
        end
      end
      # update campaigns last access
      @campaign.last_accessed = Time.now.utc
      @campaign.save
    end

    def valid_date(message)
      if message.m_moment.to_i > @campaign.c_start.to_i && message.m_moment.to_i < @campaign.c_end.to_i &&
         message.m_moment.to_i > @campaign.last_accessed.to_i
        true
      else
        false
      end
    end
end
