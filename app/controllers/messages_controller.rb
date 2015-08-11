class MessagesController < ApplicationController
  before_action :set_campaign, only: [:index, :new, :create]
  before_action :set_message, only: [:update, :destroy]

  # GET /messages
  def index
    sorted_campaign_messages = @campaign.messages.order(m_moment: :desc)
    @params = params
    if params.present? && params[:search].present?
      if params[:search][:tag_id].present?
        tag_id = params[:search][:tag_id]
        sorted_campaign_messages = sorted_campaign_messages.where("tags.id = ?", tag_id)
                                                           .joins(:tags)
      end
      if params[:search][:category_id].present?
        category_id = params[:search][:category_id]
        sorted_campaign_messages = sorted_campaign_messages.where("category_id = ?", category_id)
      end
      if params[:search][:sentiment_id].present?
        sentiment_id = params[:search][:sentiment_id]
        sorted_campaign_messages = sorted_campaign_messages.where("sentiment_id = ?", sentiment_id)
      end
      if params[:search][:origin].present?
        origin = params[:search][:origin]
        sorted_campaign_messages = sorted_campaign_messages.where("m_origin = ?", origin)
      end
    end
    if sorted_campaign_messages.present?
      page_before = params[:page].to_i - 1
      last_message_before = sorted_campaign_messages.page(page_before).per(20).last
      @prev_message_date = view_context.message_date(last_message_before.m_moment)
      @messages = sorted_campaign_messages.page(params[:page]).per(20)
    end
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
    @message = Message.new(message_params)
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
  def update
    if params.present?
      @message.update_attributes(params.permit(:m_rating, :sentiment_id, :category_id))
      if params[:m_rating].present?
        m_rating = params[:m_rating].to_i
        case m_rating
        when 1
          @rating = 1
        when 2
          @rating = 2
        else
          @rating = 0
        end
      end
      if params[:sentiment_id].present?
        @sentiment = params[:sentiment_id].to_i
      end
      @category = "nil";
      @category_id = 0;
      if params[:category_id].present?
        @category = Category.find(params[:category_id].to_i).cat_name
        @category_id = params[:category_id].to_i
      end
    end
  end

  # DELETE /messages/1
  def destroy
    message_tags = @message.tags
    if @message.destroy
      message_tags.each do |t|
        t.decrement!(:t_count)
      end
      @messages_count = @message.campaign.messages.count
      respond_to do |format|
        format.js
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_campaign
      @campaign = Campaign.find(params[:id])
    end

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
