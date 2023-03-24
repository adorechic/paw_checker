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
      p consts.map(&:value).map(&:value).uniq
    end
  end
end
