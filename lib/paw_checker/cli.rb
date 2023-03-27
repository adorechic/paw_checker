require 'thor'
require 'syntax_tree'

module PawChecker
  class CLI < Thor
    desc "structure [path]", "Run!"
    def structure(path)
      source = SyntaxTree.read(path)
      var_refs = SyntaxTree.search(source, "VarRef")
      consts = var_refs.select {|node|
        node.value.instance_of?(SyntaxTree::Const)
      }
      puts "#dependency"
      p consts.map(&:value).map(&:value).uniq

      commands = SyntaxTree.search(source, "Command")
      belongs = commands.select {|node|
        node.child_nodes.first.value == "belongs_to"
      }.map {|node|
        node.child_nodes[1].child_nodes.first.child_nodes.first.value
      }
      puts "#belongs_to"
      p belongs
      has_manies = commands.select {|node|
        node.child_nodes.first.value == "has_many"
      }.map {|node|
        node.child_nodes[1].child_nodes.first.child_nodes.first.value
      }
      puts "#has_many"
      p has_manies

      has_ones = commands.select {|node|
        node.child_nodes.first.value == "has_one"
      }.map {|node|
        node.child_nodes[1].child_nodes.first.child_nodes.first.value
      }
      puts "#has_one"
      p has_ones
    end
  end
end
