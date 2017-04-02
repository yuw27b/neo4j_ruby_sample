require 'neo4j-core'

tsv_file = ARGV[0]
neo4jpwd = ARGV[1]

Neo4j::Session.open(:server_db, "http://neo4j:#{neo4jpwd}@localhost:7474")

nodes = []
relations = []
File.open(tsv_file).each_line do |l|
  pref_from, prefs = l.chomp.split("\t")
  prefs.to_s.split(',').each do |pref|
    relations.push([pref_from, pref.strip])
  end
  nodes.push(pref_from)
end

nodes.uniq.each do |node|
  Neo4j::Node.create({name: node}, :Pref)
end

relations.uniq.each do |rel|
  nodeFrom = Neo4j::Label.find_nodes(:Pref, :name, rel[0])
  nodeTo = Neo4j::Label.find_nodes(:Pref, :name, rel[1])
  nodeFrom.each do |n1|
    nodeTo.each do |n2|
      n1.create_rel(:Adjoin, n2)
    end
  end
end
