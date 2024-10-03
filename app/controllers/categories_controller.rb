class CategoriesController < ApplicationController
  before_action :set_category, only: %i[ show edit update destroy ]

  # GET /categories or /categories.json
  def index
    @categories = Category.all.where(parent_category_id: nil)
  end

  # GET /categories/1 or /categories/1.json
  def show
  end

  # GET /categories/new
  def new
    @categories = Category.all.where(level: 1, parent_category_id: nil)
    @category = Category.new
  end

  def new_with_select
    puts "Here with request params: #{params}"
    level = params["level"].to_i

    begin
      current_selected = Category.find(params["id"].to_i)
    rescue ActiveRecord::RecordNotFound

      # Return an empty category
      current_selected = Category.new parent_category_id: ""

      respond_to do |format|
        format.turbo_stream do
          puts "Rendering empty turbo"
          render turbo_stream: turbo_stream.replace("category_#{level + 1}", partial: "categories/empty_subcategory",
          locals: { level: level + 1 })
        end
      end
      return
    end


    categories = Category.all.where(parent_category_id: current_selected.parent_category_id)
    sub_categories = Category.all.where(parent_category_id: current_selected.id)

    respond_to do |format|
      format.html { render plain: "heelo Wold" }
      format.turbo_stream do
        puts "Rendering turbooo"
        render turbo_stream: turbo_stream.replace("category_#{level}", partial: "categories/subcategory_select",
        locals: { categories: categories, level: level, sub_categories: sub_categories, selected_id: params["id"], selected_parent: nil })
      end
    end
  end

  # GET /categories/1/edit
  def edit
  end

  # POST /categories or /categories.json
  def create
    category_selected_param = get_category_selected_params


    new_category_params = category_params
    new_category_params["parent_category_id"] = category_selected_param["id"]
    new_category_params["created_by"] = "dummy"

    @category = Category.new(new_category_params)

    puts "Formed Category From Params: #{@category}"

    respond_to do |format|
      if @category.save
        format.html { redirect_to category_url(@category), notice: "Category was successfully created." }
        format.json { render :show, status: :created, location: @category }
      else
        format.html { redirect_to new_category_path, status: :unprocessable_entity, notice: "Could not save entity #{@category.errors}" }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /categories/1 or /categories/1.json
  def update
    respond_to do |format|
      if @category.update(category_params)
        format.html { redirect_to category_url(@category), notice: "Category was successfully updated." }
        format.json { render :show, status: :ok, location: @category }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /categories/1 or /categories/1.json
  def destroy
    @category.destroy!

    respond_to do |format|
      format.html { redirect_to categories_url, notice: "Category was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_category
      @category = Category.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def category_params
      params.fetch(:category).permit!
    end

    def get_category_selected_params
      d = {}
      d["id"] = nil

      subcategory_regex = /^subcategory_(\d+)$/

      filtered = params.each.select do |key, val|
          if key.match subcategory_regex
              true
          end
      end

      mx = -1


      filtered.each do |key, val|
        _, key_num = key.split "_"
        key_num = key_num.to_i

        if key_num > mx
          next if val.empty? or val.to_i == 0
          mx = key_num
          d["id"] = val.to_i
        end
      end
      d
    end
end
