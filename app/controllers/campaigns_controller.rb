class CampaignsController < ApplicationController
  before_action :set_campaign, only: [:show, :edit, :update, :destroy]

  # GET /campaigns/1
  def show
    # deactivate past campaign
    if @campaign.c_end < Time.now
      @campaign.update_attributes(c_status: 0)
    end
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
    @campaign = Campaign.new(campaign_params)
    @campaign.c_end = set_end_date_minutes(@campaign.c_end)
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
      @campaign.update_attributes(campaign_params)
      respond_to do |format|
        format.html { redirect_to campaign_path(@campaign) }
      end
    else
      cloned_campaign_params = campaign_params.clone
      cloned_campaign_params[:c_end] = set_end_date_minutes(campaign_params[:c_end])
      respond_to do |format|
        if @campaign.update_attributes(cloned_campaign_params)
          format.html { redirect_to campaign_path(@campaign) }
        else
          format.html { render "edit" }
        end
      end
    end
  end

  # DELETE /campaigns/1
  def destroy
    # @campaign.destroy
    @campaign.update_attributes(last_accessed: nil)
    respond_to do |format|
      format.html { redirect_to root_path }
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

    # set time of end date to 23:59:59
    def set_end_date_minutes(c_end)
      "#{c_end} 23:59:59"
    end
end
