class CampaignsController < ApplicationController
  before_action :set_campaign, only: [
                                       :show, :edit, :update, :destroy, :messages_in_period,
                                       :top_15_tags
                                     ]

  # GET /campaigns/1
  def show
  end

  # GET /campaigns
  def index
    @campaigns = Campaign.all
  end

  # GET /campaigns/new
  def new
    @campaign = Campaign.new
  end

  # GET /campaigns/1/edit
  def edit
  end

  # POST /campaigns
  def create
    @campaign = Campaign.create(campaign_params)
    respond_to do |format|
      if @campaign.save
        format.html { redirect_to campaign_path(@campaign) }
      else
        format.html { render "new" }
      end
    end
  end

  # PATCH/PUT /campaigns/1
  def update
    if campaign_params[:c_status].present?
      # on updating the campaign status from the left navigation just reload the page
      # because you can do it from every view with the navigation option
      @campaign.update_attributes(campaign_params)
      respond_to do |format|
        format.html { redirect_to :back } # refresh current view
      end
    else
      respond_to do |format|
        if @campaign.update(campaign_params)
          format.html { redirect_to campaign_path(@campaign) }
        else
          format.html { render "edit" }
        end
      end
    end
  end

  # DELETE /campaigns/1
  def destroy
    @campaign.destroy
    respond_to do |format|
      format.html { redirect_to root_path }
    end
  end

  # GET /campaigns/1/messages_in_period
  def messages_in_period
    # [["10.06.2015", 50], ["11.06.2015", 40]]
    @campaign_messages = @campaign.messages.order(m_moment: :asc)
                                           .group_by{ |m| view_context.message_date(m.m_moment)}
                                           .collect do |date, messages|
                                             [date, messages.count]
                                           end
    respond_to do |format|
      format.json {
        render json: { responseText: @campaign_messages.unshift(["Tag", "Anzahl"]).to_json }
      }
    end
  end

  # GET /campaigns/1/top_15_tags
  def top_15_tags
    # [["tag1", 10], ["tag2", 5]]
    @campaign_tags = @campaign.tags.order(t_count: :desc).take(15).collect do |tag|
      [tag.t_name, tag.t_count]
    end
    respond_to do |format|
      format.json {
        render json: { responseText: @campaign_tags.unshift(["Tag", "Anzahl"]).to_json }
      }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_campaign
      @campaign = Campaign.find(params[:id])
    end

    # Using a private method to encapsulate the permissible parameters is just a good pattern
    # since you'll be able to reuse the same permit list between create and update. Also, you
    # can specialize this method with per-user checking of permissible attributes.
    def campaign_params
      params.require(:campaign).permit(:c_name, :c_description, :c_start, :c_end, :c_status,
                                       :last_accessed)
    end
end
