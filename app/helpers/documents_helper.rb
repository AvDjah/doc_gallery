require "pdf-reader"

module DocumentsHelper
  ###
  # @description: Saves the document received from a request
  # @param params: Hash
  # @param file_name: String
  # @return {any}:
  ###
  Valid_mime_types = [ "application/pdf", "application/x-pdf", "application/acrobat" ]

  def check_valid_pdf(pdf_file)
    begin
      return false if pdf_file == nil
      mime_type = Marcel::MimeType.for pdf_file
      if !Valid_mime_types.include? mime_type
        puts "File type not valid as mimetype we got is: #{mime_type}"
        return false
      end
      true
    rescue => e
      puts "Error reading file mime_type: #{e}"
      false
    end
  end

  def save_document_file(uploaded_file, file_name)
    if uploaded_file
      # Define the path where you want to save the file
      begin

        return false if !check_valid_pdf uploaded_file

        storage_directory = Rails.root.join("storage", "documents")

        # Create the directory if it doesn't exist
        FileUtils.mkdir_p(storage_directory) unless File.directory?(storage_directory)

        # Define the full path for the new file
        file_path = storage_directory.join(file_name + ".pdf")

        # Save the file
        File.open(file_path, "wb") do |file|
          file.write(uploaded_file.read)
        end
        return true
      rescue Exception => e
        puts "Error saving file: #{e}"
        return false
      end
    end
    true
  end

  def extract_content_from_pdf(pdf_file)
    begin

      return [ false, "" ] if !pdf_file.present?
      return [ false, "" ] if !check_valid_pdf pdf_file

      reader = PDF::Reader.new(pdf_file.tempfile)
      text_content = ""
      reader.pages.each do |page|
        text_content << page.text
        text_content << " "
      end
      [ true, text_content ]
    rescue => e
      puts "Error reading file content: #{e}"
      [ false, "" ]
    end
  end

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
