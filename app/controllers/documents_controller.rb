require "securerandom"

class DocumentsController < ApplicationController
  include ApplicationHelper
  include DocumentsHelper
  include ElasticHelper

  before_action :set_document, only: %i[ show edit update destroy ]

  # GET /documents or /documents.json
  def index
    @search_query = params["search_query"]

    if @search_query != nil and @search_query.length > 0
      result = elastic_search_content @search_query.to_s
    end

    @result = nil
    if result != nil
      @result = result["hits"]["hits"]
    end

    @documents = Document.all

    respond_to do |format|
      format.html { render :index }
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("results", partial: "results")
      end
    end
  end

  # GET /documents/1 or /documents/1.json
  def show
  end

  # GET /documents/new
  def new
    @document = Document.new
    @categories = Category.all.where(level: 1, parent_category_id: nil)
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

  # GET /documents/1/edit
  def edit
  end

  # POST /documents or /documents.json
  def create
    category_selected_param = get_category_selected_params params

    document_text_content = params["text_content"]["text"]


    if category_selected_param["id"] == nil
      @document = Document.new
      @document.errors.add("", "Please select a category. It cannot be empty.")
      @categories = Category.all.where(level: 1, parent_category_id: nil)
      render :new, status: :unprocessable_entity
      return
    end

    document_params["parent_category_id"] = category_selected_param["id"]
    @document = Document.new(document_params)
    document_uuid = SecureRandom.uuid.to_s

    @document.document_guid = document_uuid

    uploaded_file = params[:document_file]

    save_result = save_document_file uploaded_file, document_uuid
    if save_result == true
      pdf_content_text = extract_content_from_pdf uploaded_file
      if pdf_content_text[0] != false and pdf_content_text[1] != ""
        index_document_result = save_data_to_elastic @document, pdf_content_text
      end
    end


    respond_to do |format|
      if @document.save

        if !document_text_content.empty?
          index_document_result = save_data_to_elastic @document, document_text_content
          if index_document_result == false
            puts "Could not index document data, hence discarding document."
            @document.destroy!
          else
            puts "Successfully indexed document"
          end
        end

        format.html { redirect_to documents_path, notice: "Document was successfully created." }
        format.json { render :show, status: :created, location: @document }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /documents/1 or /documents/1.json
  def update
    respond_to do |format|
      if @document.update(document_params)
        format.html { redirect_to document_url(@document), notice: "Document was successfully updated." }
        format.json { render :show, status: :ok, location: @document }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /documents/1 or /documents/1.json
  def destroy
    @document.destroy!

    respond_to do |format|
      format.html { redirect_to documents_url, notice: "Document was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_document
      @document = Document.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def document_params
      params.fetch(:document, {}).permit!
    end

  ###
  # @description: Creates an hash to be inserted in the elastic search index
  # @param document: Document
  # @return {any}: Hash
  ###
end
