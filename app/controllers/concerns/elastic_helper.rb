

module ElasticHelper
  def elastic_search_content(search_text)
    begin
      wildcard_search_text = "*#{search_text}*"
      response = Elastic_client.search(index: Elastic_index_name, q: wildcard_search_text)
      response
    rescue => e
      puts "Error searching in elastic_client: #{e}"
      []
    end
  end
end
