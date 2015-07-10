class InstagramController < ApplicationController
  before_action :set_client, only: [:instagrams]
  before_action :set_campaign, only: [:instagrams]

  # get instagrams for a campaign
  def instagrams
    @last_saved_instagram_id = 0
    if @campaign.c_status == 1
      @last_saved_instagram_id = get_instagram_data(@client, create_query, nil)
    end
    respond_to do |format|
      format.json
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_client
      Instagram.configure do |config|
        config.client_id = Rails.application.secrets.instagram["client_id"]
        config.client_secret = Rails.application.secrets.instagram["client_secret"]
      end
      @client = Instagram.client(access_token: session[:access_token])
    end

    def set_campaign
      @campaign = Campaign.find(params[:id])
    end

    def create_query
      query_array = []
      @campaign.tags.where(t_connection: nil).each do |tag|
        query_array << CGI.escape(tag.t_name)
      end
      query_array
    end

    def get_instagram_data(client, query_array, min_id)
      last_instagram_id = "0"
      options = {}
      if min_id.present? && min_id != "0"
        options[:min_id] = min_id
      end
      query_array.each do |query|
        client.tag_recent_media(query, options).each do |instagram|
          message = Message.new(campaign_id: @campaign.id)
          message = view_context.create_instagram_message(message, instagram)
          if valid_date(message)
            if message.save
              last_instagram_id = instagram.id
            end
          end
        end
        if last_instagram_id != "0"
          last_instagram_id = get_instagram_data(client, query_array, last_instagram_id)
        end
      end
      # mark access to finish requesting past tweets
      @campaign.last_accessed = Time.now.utc
      @campaign.save
      last_instagram_id
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
