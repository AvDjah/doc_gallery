

module ElasticHelper
  def elastic_search_content(search_text)
    response = Elastic_client.search(index: Elastic_index_name, q: search_text)
    response
  end
end
