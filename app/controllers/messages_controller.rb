class MessagesController < ApplicationController
  before_action :set_message, only: []
  before_action :set_campaign, only: [:index, :new, :create]
  after_action :set_message_tags, only: [:create]

  # GET /messages
  def index
    @messages = @campaign.messages.order(m_moment: :desc)
  end

  # GET /messages/new
  def new
    @message = Message.new
  end

  # GET /messages/1/edit
  def edit
  end

  # POST /messages
  def create
    @message = Message.create(message_params)
    respond_to do |format|
      if @message.save
        format.html { redirect_to campaign_path(@campaign) }
      else
        format.html { render "new" }
      end
    end
  end

  # PATCH/PUT /messages/1
  def updates
  end

  # DELETE /messages/1
  def destroy
  end

  private
    # check message text for campaign tags and save matching tags to the message
    def set_message_tags
      campaign_tags = @campaign.tags.map{ |t| t.t_name.downcase }.uniq
      message_words = @message.m_text.downcase.gsub('#', '').gsub('.', '').split(' ').uniq
      message_tags = campaign_tags & message_words
      message_tags.each do |tag|
        MessageTag.create(message_id: @message.id,
                          tag_id: @campaign.tags.where(t_name: tag).first.id)
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @message = Message.find(params[:id])
    end

    def set_campaign
      @campaign = Campaign.find(params[:id])
    end

    # Using a private method to encapsulate the permissible parameters is just a good pattern
    # since you'll be able to reuse the same permit list between create and update. Also, you
    # can specialize this method with per-user checking of permissible attributes.
    def message_params
      params.require(:message).permit(:m_author, :m_text, :m_moment, :m_origin, :m_details,
                                      :m_rating, :campaign_id, :category_id, :sentiment_id)
    end
end
