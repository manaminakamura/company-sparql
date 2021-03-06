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
      SELECT DISTINCT ?name ?abstract (MIN(?num) AS ?number_of_employees) (MIN(?rep) AS ?representative)

      WHERE {
        ?company dbp-owl:wikiPageWikiLink <http://ja.dbpedia.org/resource/Category:東証一部上場企業> .
        ?company rdfs:label ?name .
        ?company dbp-owl:abstract ?abstract .
        ?company dbp-owl:numberOfEmployees ?num .
        ?company prop-ja:代表者 ?rep .
        ?rep rdf:type dbp-owl:Person .
      }
      GROUP BY ?company ?abstract ?name
      LIMIT #{limit}
    ".force_encoding("ASCII-8BIT")
    results = client.query(query_string)
  end

  def key_person_info(client=nil, key_person)
    client ||= get_client
    query_string = "
      #{PREFIXES}
      SELECT DISTINCT ?name ?univ_name
      WHERE {
        <#{key_person}> rdfs:label ?name .
        <#{key_person}> dbp-owl:wikiPageWikiLink ?univ.
        ?univ rdf:type dbp-owl:University .
        ?univ rdfs:label ?univ_name .
      }
    ".force_encoding("ASCII-8BIT")
    results = client.query(query_string)
  end

  def associate_company(client=nil, limit=10, name)
    client ||= get_client
    query_string = "
    #{PREFIXES}
    SELECT DISTINCT ?name
    WHERE {
      ?company rdf:type dbp-owl:Company .
      ?company dbp-owl:wikiPageWikiLink dbp:#{name} .
      ?company rdfs:label ?name .
    }
    LIMIT #{limit}
    "
    begin
      results = client.query(query_string)
    rescue => e
      return []
    end
  end

end

if __FILE__ == $0
  include Dbpedia
  client = get_client
  res = tse_companies(client, 30)
  res.each do |item|
    name = item.to_h[:name].to_s
    p name
    p item.to_h[:abstract].to_s
    p item.to_h[:number_of_employees].to_s
    
    representative = item.to_h[:representative].to_s
    unless representative == "http://ja.dbpedia.org/resource/代表取締役" || representative == "http://ja.dbpedia.org/resource/取締役"
      res = key_person_info(client, representative)
      p res[0].to_h[:name].to_s + ", " + res[0].to_h[:univ_name].to_s
    end

    res = associate_company(client, 10, name)
    association = res.map do |company|
      company.to_h[:name].to_s
    end
    p association
    p "----------"
  end
end

