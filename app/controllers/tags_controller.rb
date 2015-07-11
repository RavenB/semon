class TagsController < ApplicationController
  before_action :set_campaign, only: [:create, :update, :destroy]
  before_action :set_tag, only: [:edit, :update, :destroy]
  respond_to :js

  # GET /tags
  def index
    @campaign = Campaign.find(params[:id])
    @tag = Tag.new
    @tags_json = view_context.treeview_json(Tag.for_campaign(params[:id]).order(:t_name))
  end

  # POST /tags
  def create
    @tag = Tag.new(tag_params)
    @tag.t_name = @tag.t_name.delete(" ")
    @tag.save
    @tags_json = view_context.treeview_json(Tag.for_campaign(tag_params[:campaign_id]))
    flash[:success] = "Erfolgreich aktualisiert!"
  end

  # PATCH/PUT /tags/1
  def update
    @tag.update_attributes(tag_params)
    @tags_json = view_context.treeview_json(Tag.for_campaign(tag_params[:campaign_id]))
    flash[:success] = "Erfolgreich aktualisiert!"
  end

  # DELETE /tags/1
  def destroy
    @tag.destroy
    @tags_json = view_context.treeview_json(Tag.for_campaign(tag_params[:campaign_id]))
    if @campaign.tags.count == 0
      # deactivate campaign when all tags deleted
      @campaign.update_attributes(c_status: "0")
    end
    flash[:success] = "Erfolgreich aktualisiert!"
  end

  # returns the html template in views/tags/templates
  def tag_edit_list_item
    @new_tag = Tag.new
    @campaign_id = params[:campaign_id]
    @current_tag = Tag.find_by_id(params[:current_tag_id])
    @tag_ancestry = params[:ancestry]
    respond_to do |format|
      format.html { render "tags/templates/tag_edit_list_item", layout: false }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tag
      @tag = Tag.find(params[:id])
    end

    def set_campaign
      @campaign = Campaign.find(tag_params[:campaign_id])
    end

    # Using a private method to encapsulate the permissible parameters is just a good pattern
    # since you'll be able to reuse the same permit list between create and update. Also, you
    # can specialize this method with per-user checking of permissible attributes.
    def tag_params
      params.require(:tag).permit(:t_name, :ancestry, :t_count, :t_connection, :campaign_id)
    end
end
