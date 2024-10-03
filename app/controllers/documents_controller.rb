require "securerandom"

class DocumentsController < ApplicationController
  include ApplicationHelper
  include DocumentsHelper
  include ElasticHelper

  before_action :set_document, only: %i[ show edit update destroy ]

  # GET /documents or /documents.json
  def index
    search_query = params["search_query"]

    if search_query != nil and search_query.length > 0
      result = elastic_search_content search_query.to_s
    end

    @result = nil
    if result != nil
      @result = result["hits"]["hits"]
    end

    @documents = Document.all
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

    save_document_file params, document_uuid


    respond_to do |format|
      if @document.save

        index_document_result = save_data_to_elastic @document, document_text_content

        if index_document_result == false
          puts "Could not index document data, hence discarding document."
          @document.destroy!
        else
          puts "Successfully indexed document"
        end

        format.html { redirect_to document_url(@document), notice: "Document was successfully created." }
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
    def get_hash_data_of_document(document)
      h_doc = {
        category_name: document.parent_category.name,
        created_by: document.parent_category.created_by,
        title: document.title,
        id: document.id
      }
      h_doc
    end

    def save_data_to_elastic(document, text_content)
      begin
        document_h = get_hash_data_of_document document
        document_h["text_content"] = text_content

        Elastic_client.index(index: Elastic_index_name, body: document_h)
        true
      rescue => e
        puts "Error indexing document: #{e}"
        false
      end
    end
end
