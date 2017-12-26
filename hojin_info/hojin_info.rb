require 'sparql/client'

module HojinInfo
  PREFIXES = "
    PREFIX hj: <http://hojin-info.go.jp/ns/domain/biz/1#>
    PREFIX ic: <http://imi.go.jp/ns/core/rdf#>
  "
  GRAPH_HOJIN      = "<http://hojin-info.go.jp/graph/hojin>"
  GRAPH_HOJYOKIN   = "<http://hojin-info.go.jp/graph/hojyokin>"
  GRAPH_CHOTATSU   = "<http://hojin-info.go.jp/graph/chotatsu>"
  GRAPH_HYOSHO     = "<http://hojin-info.go.jp/graph/hyosho>"
  GRAPH_TODOKEDE   = "<http://hojin-info.go.jp/graph/todokede>"
  GRAPH_COMMONCODE = "<http://hojin-info.go.jp/graph/commonCode>"

  def get_client
    SPARQL::Client.new('http://api.hojin-info.go.jp/sparql')
  end

  def get_all_hojin_id(client=nil, limit)
    client ||= get_client

    query_string = "
      #{PREFIXES}
      SELECT ?id FROM #{GRAPH_HOJIN}
      WHERE {
        ?s hj:法人基本情報 ?key .
        ?key ic:ID/ic:識別値 ?id .
      }
      limit #{limit}
    "
    results = client.query(query_string)
  end


  def get_name(client=nil, id)
    client ||= get_client
    query_string = "
      #{PREFIXES}
      SELECT ?name FROM #{GRAPH_HOJIN}
      WHERE {
        ?s hj:法人基本情報 ?key .
        ?key ic:ID/ic:識別値 '#{id}' .
        ?key ic:名称/ic:表記 ?name
      }
    "
    results = client.query(query_string)
  end

  def get_hojin_base_info(client=nil, id)
    client ||= get_client
    query_string = "
      #{PREFIXES}
      SELECT DISTINCT * FROM #{GRAPH_HOJIN}
      WHERE {
        ?s hj:法人基本情報 ?key .
        ?key ic:ID/ic:識別値 '#{id}' .
        ?key ic:ID/ic:識別値 ?id .
        OPTIONAL{?key ic:名称/ic:表記 ?name .}
        OPTIONAL{?key ic:住所/ic:表記 ?address .}
        OPTIONAL{?key ic:住所/ic:郵便番号 ?zip_code .}
        OPTIONAL{?key ic:住所/ic:都道府県 ?prefecture .}
        OPTIONAL{?key ic:住所/ic:市区町村 ?city .}
        OPTIONAL{?key ic:住所/ic:丁目番地等 ?chome .}
        OPTIONAL{?key ic:活動状況/ic:発生日 ?start_day .}
        OPTIONAL{?key ic:活動状況/ic:説明 ?status .}
        OPTIONAL{?key ic:更新日時/ic:標準型日時 ?updated_at .}
      }
    "
    results = client.query(query_string)
  end
end

if __FILE__ == $0
  include HojinInfo
  client = get_client
  ids = get_all_hojin_id(client, 10)
  ids.each do |item|
    id = item.id.to_s
    name = get_name(client, id)[0].to_h[:name].to_s
    p name
    base_info = get_hojin_base_info(client, id)[0].to_h
    p base_info[:address].to_s
  end
end
