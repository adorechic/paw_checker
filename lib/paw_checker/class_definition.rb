require 'gviz'
require 'active_support'
require 'active_support/core_ext'

module PawChecker
  class ClassDefinition
    class << self
      def parse(path)
        source = SyntaxTree.read(path)
        cls = ClassDefinition.new(source)
        cls.pretty_print
      end
    end

    def initialize(source)
      idx = SyntaxTree.index(source)
      @class_name = idx.find {|i|
        i.instance_of?(SyntaxTree::Index::ClassDefinition)
      }.name.to_sym
      @var_refs = SyntaxTree.search(source, "VarRef")
      @commands = SyntaxTree.search(source, "Command")
    end

    def pretty_print
      name = @class_name
      depends = dependencies + belongs + has_manies + has_ones

      Graph do
        route name => depends
        save(:output, :png)
      end
    end

    private

    def dependencies
      @dependencies ||= consts.map(&:value).map(&:value).uniq.map(&:to_sym)
    end

    def consts
      @var_refs.select {|node|
        node.value.instance_of?(SyntaxTree::Const)
      }
    end

    def belongs
      @belongs ||= pick_association_commands("belongs_to")
    end

    def has_manies
      @has_manies ||= pick_association_commands("has_many")
    end

    def has_ones
      @has_ones ||= pick_association_commands("has_one")
    end

    def pick_association_commands(type)
      @commands.select {|node|
        node.child_nodes.first.value == type
      }.map {|node|
        node.child_nodes[1].child_nodes.first.child_nodes.first.value.classify.to_sym
      }
    end
  end
end
