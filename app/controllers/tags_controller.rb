class TagsController < ApplicationController
  before_action :set_campaign, only: [:index]
  before_action :set_tag, only: [:edit, :update, :destroy]

  # GET /tags
  # GET /tags.json
  def index
    @tags = Tag.all
  end

  # GET /tags/new
  def new
    @tag = Tag.new
  end

  # GET /tags/1/edit
  def edit
  end

  # POST /tags
  # POST /tags.json
  def create
    @tag = Tag.new(tag_params)

    respond_to do |format|
      if @tag.save
        format.html { redirect_to root_path }
        format.json { render "index", status: :created, location: @tag }
      else
        format.html { render "new" }
        format.json { render json: @tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tags/1
  # PATCH/PUT /tags/1.json
  def update
    respond_to do |format|
      if @tag.update(tag_params)
        format.html { redirect_to root_path }
        format.json { head :no_content }
      else
        format.html { render "edit" }
        format.json { render json: @tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tags/1
  # DELETE /tags/1.json
  def destroy
    @tag.destroy
    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tag
      @tag = Tag.find(params[:id])
    end

    def set_campaign
      @campaign = Campaign.find(params[:id])
    end

    # Using a private method to encapsulate the permissible parameters is just a good pattern
    # since you'll be able to reuse the same permit list between create and update. Also, you
    # can specialize this method with per-user checking of permissible attributes.
    def tag_params
      params.require(:tag).permit(:t_name, :ancestry, :t_count, :t_connection, :campaign_id)
    end
end
