require 'neo4j-core'

neo4jpwd = ARGV[0]

Neo4j::Session.open(:server_db, "http://neo4j:#{neo4jpwd}@localhost:7474")

### Search node
n = Neo4j::Session.query("MATCH (a{name: '新潟県'})-[*2]->(b) RETURN DISTINCT b.name")
res = n.to_a.map{|node| node['b.name']}
p res

# n = Neo4j::Session.query.match('a-[*2]->(b)').where(a: {name: '新潟県'}).pluck('DISTINCT b.name')
# res = n.to_a.map{|node| node['b.name']}
# p res


### Shortest path
n = Neo4j::Session.query("
  MATCH path=allShortestPaths((a)-[*0..10]->(b))
  WHERE (a.name = '新潟県')
  AND (b.name = '神奈川県')
  AND ALL (x IN RELATIONSHIPS(path) WHERE x.connection = 'road')
  RETURN path
")
#neo4j-coreのバグ(?)で、RESTfulAPIのURIが返ってきてしまうので、Nodeの情報に戻す　https://github.com/neo4jrb/neo4j-core/issues/200
path = n.to_a.map{|nodes|
  node_id = nodes.split('/').last.to_i
  node = Neo4j::Node.load(node_id)
  node[:name]
}
p path
