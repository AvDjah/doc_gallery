

module ElasticHelper
  def elastic_search_content(search_text)
    # escaped_search_text = Elastic::Model.escape(search_text)

    # Use wildcard syntax for matching substrings
    wildcard_search_text = "*#{search_text}*"

    response = Elastic_client.search(index: Elastic_index_name, q: wildcard_search_text)

    response
  end
end
