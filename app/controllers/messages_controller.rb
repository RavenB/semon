class MessagesController < ApplicationController
  before_action :set_message, only: []

  # GET /messages
  def index
    @messages = Message.all
    # TODO only messages for a campaign
    # index = timeline
  end

  # GET /messages/new
  def new
    @campaign = Campaign.find(params[:id])
    @message = Message.new
  end

  # GET /messages/1/edit
  def edit
  end

  # POST /messages
  def create
    @campaign = Campaign.find(params[:id])
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
  def update
  end

  # DELETE /messages/1
  def destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @message = Message.find(params[:id])
    end

    # Using a private method to encapsulate the permissible parameters is just a good pattern
    # since you'll be able to reuse the same permit list between create and update. Also, you
    # can specialize this method with per-user checking of permissible attributes.
    def message_params
      params.require(:message).permit(:m_author, :m_text, :m_moment, :m_origin, :m_details,
                                      :m_rating, :campaign_id, :category_id, :sentiment_id)
    end
end
