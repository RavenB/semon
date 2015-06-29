class MessagesController < ApplicationController
  before_action :set_campaign, only: [:index, :new, :create]

  # GET /messages
  def index
    page_before = params[:page].to_i - 1
    last_message_before = @campaign.messages.order(m_moment: :desc).page(page_before).per(20).last
    @prev_message_date = view_context.message_date(last_message_before.m_moment)
    @messages = @campaign.messages.order(m_moment: :desc).page(params[:page]).per(20)
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
    @message.m_text = view_context.escape_text_characters(@message.m_text)
    if params[:message][:m_details][:manual].present?
      @message.m_details = view_context.manual_details_json(params[:message][:m_details])
    end
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
    # Use callbacks to share common setup or constraints between actions.
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
