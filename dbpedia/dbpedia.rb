require 'sparql/client'

module Dbpedia
  PREFIXES = "
    PREFIX dbp:<http://ja.dbpedia.org/resource/>
    PREFIX dbp-owl:<http://dbpedia/ontology/>
  "

  def get_client
    SPARQL::Client.new('http://ja.dbpedia.org/sparql')
  end

  def ping
    client ||= get_client
    query_string = "
      SELECT ?s ?p ?o
      WHERE {
      ?s ?p ?o .
      }
      LIMIT 100
    "
    results = client.query(query_string)
  end
end

if $0 == __FILE__
  include Dbpedia
  res = ping
  p res
end

