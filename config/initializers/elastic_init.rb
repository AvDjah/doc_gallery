
Elastic_client = Elasticsearch::Client.new(
  user: ENV["ELASTICSEARCH_USER"],
  password: ENV["ELASTICSEARCH_PASSWORD"]
)

begin
  response = Elastic_client.info
  puts "Client Connected!!!! #{response}"
rescue => e
  puts "Error connecting to client : #{e}"
end

Elastic_index_name = "my_index"

# Elastic_client.indices.create(index: Elastic_index_name)
