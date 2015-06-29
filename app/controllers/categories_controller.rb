class CategoriesController < ApplicationController
  before_action :set_category, only: [:edit, :update, :destroy]

  # GET /categories
  def index
    @categories = Category.order(:cat_name).all
  end

  # GET /categories/new
  def new
    @category = Category.new
  end

  # GET /categories/1/edit
  def edit
  end

  # POST /categories
  def create
    @category = Category.create(category_params)
    respond_to do |format|
      if @category.save
        format.html { redirect_to categories_path }
      else
        format.html { render "new" }
      end
    end
  end

  # PATCH/PUT /categories/1
  def update
    respond_to do |format|
      if @category.update(category_params)
        format.html { redirect_to categories_path }
      else
        format.html { render "edit" }
      end
    end
  end

  # DELETE /categories/1
  def destroy
    @category.destroy
    respond_to do |format|
      format.html { redirect_to categories_path }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_category
      @category = Category.find(params[:id])
    end

    # Using a private method to encapsulate the permissible parameters is just a good pattern
    # since you'll be able to reuse the same permit list between create and update. Also, you
    # can specialize this method with per-user checking of permissible attributes.
    def category_params
      params.require(:category).permit(:cat_name, :cat_description)
    end
end
