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
      SELECT DISTINCT ?name ?abstract ?number_of_employees ?key_person
      WHERE {
        ?company dbp-owl:wikiPageWikiLink <http://ja.dbpedia.org/resource/Category:東証一部上場企業> .
        ?company rdfs:label ?name .
        ?company dbp-owl:abstract ?abstract .
        ?company dbp-owl:numberOfEmployees ?number_of_employees .
        ?company dbp-owl:keyPerson ?key_person .
      }
      LIMIT #{limit}
    "
    results = client.query(query_string)
  end

  def key_person_info(client=nil, key_person)
    client ||= get_client
    query_string = "
      #{PREFIXES}
      SELECT DISTINCT ?name
      WHERE {
        ?person dbp:#{key_person}
        ?person rdfs:label ?name .
      }
    "
    begin
      results = client.query(query_string)
    rescue => e
      return []
    end
  end

  def associated_person(client=nil, limit=10, name)
    client ||= get_client
    query_string = "
    #{PREFIXES}
    SELECT DISTINCT ?name
    WHERE {
      ?person rdf:type dbp-owl:Person .
      ?person dbp-owl:wikiPageWikiLink dbp:#{name} .
      ?person rdfs:label ?name .
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

if $0 == __FILE__
  include Dbpedia
  client = get_client
  res = tse_companies(client)
  res.each do |item|
    name = item.to_h[:name].to_s
    p name
    p item.to_h[:abstract].to_s
    p item.to_h[:number_of_employees].to_s

    key_person = item.to_h[:key_person].to_s
    unless key_person == "http://ja.dbpedia.org/resource/代表取締役"
      res = key_person_info(client, key_person)
      p res[0].to_h[:name].to_s
    end

    res = associated_person(client, 10, name)
    association = res.map do |person|
      person.to_h[:name].to_s
    end
    p association
  end
end

