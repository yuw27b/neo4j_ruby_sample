require 'neo4j-core'

tsv_file = ARGV[0]
neo4jpwd = ARGV[1]

Neo4j::Session.open(:server_db, "http://neo4j:#{neo4jpwd}@localhost:7474")

nodes = []
relations = []
File.open(tsv_file).each_line do |l|
  next if l[0, 1] == '#'
  pref1, pref2, bridge_flag = l.chomp.split("\t")
  if pref1 && pref2
    relations.push([pref1, pref2, bridge_flag.to_i])
  end
  nodes.push(pref1) if pref1
  nodes.push(pref2) if pref2
end

nodes.uniq.each do |node|
  Neo4j::Node.create({name: node}, :Pref)
end

relations.uniq.each do |rel|
  nodeFrom = Neo4j::Label.find_nodes(:Pref, :name, rel[0])
  nodeTo = Neo4j::Label.find_nodes(:Pref, :name, rel[1])
  connection = rel[2] > 0 ? 'bridge' : 'road'
  nodeFrom.each do |n1|
    nodeTo.each do |n2|
      n1.create_rel(:Adjoin, n2, connection: connection)
    end
  end
end
