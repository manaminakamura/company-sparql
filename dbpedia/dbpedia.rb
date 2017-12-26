require 'sparql/client'

module Dbpedia
  PREFIXES = "
    PREFIX dbp:<http://ja.dbpedia.org/resource/>
    PREFIX dbp-owl:<http://dbpedia.org/ontology/>
  "

  def get_client
    SPARQL::Client.new('http://ja.dbpedia.org/sparql')
  end

  def tse_companies(client=nil, limit=100)
    client ||= get_client
    query_string = "
      #{PREFIXES}
      SELECT DISTINCT ?name ?abstract ?number_of_employees
      WHERE {
        ?company dbp-owl:wikiPageWikiLink <http://ja.dbpedia.org/resource/Category:東証一部上場企業> .
        ?company rdfs:label ?name .
        ?company dbp-owl:abstract ?abstract .
        ?company dbp-owl:numberOfEmployees ?number_of_employees .
      }
      LIMIT #{limit}
    "
    results = client.query(query_string)
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
  res = tse_companies
  res.each do |item|
    p item.to_h[:name].to_s
    p item.to_h[:abstract].to_s
    p item.to_h[:number_of_employees].to_s
  end
end

