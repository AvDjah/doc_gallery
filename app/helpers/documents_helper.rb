module DocumentsHelper
  ###
  # @description: Saves the document received from a request
  # @param params: Hash
  # @param file_name: String
  # @return {any}:
  ###
  def save_document_file(params, file_name)
    uploaded_file = params[:document_file]

    valid_mime_types = [ "application/pdf", "application/x-pdf", "application/acrobat" ]

    if uploaded_file
      # Define the path where you want to save the file
      begin

        mime_type = Marcel::MimeType.for uploaded_file
        if !valid_mime_types.include? mime_type
          puts "File type not valid as mimetype we got is: #{mime_type}"
        end

        storage_directory = Rails.root.join("storage", "documents")

        # Create the directory if it doesn't exist
        FileUtils.mkdir_p(storage_directory) unless File.directory?(storage_directory)

        # Define the full path for the new file
        file_path = storage_directory.join(file_name)

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
end
