require 'active_support'
require 'active_support/core_ext'

module PawChecker
  class ClassDefinition
    attr_reader :class_name

    class << self
      def parse(path)
        extract_wildcard(path).map do |epath|
          source = SyntaxTree.read(epath)
          ClassDefinition.new(source)
        end
      end

      private

      def extract_wildcard(path)
        if File.directory?(path)
          Dir.glob("#{path}/app/models/**/*.rb")
        else
          [path]
        end
      end
    end

    def initialize(source)
      idx = SyntaxTree.index(source)
      @class_name = idx.find {|i|
        i.instance_of?(SyntaxTree::Index::ClassDefinition) ||
          i.instance_of?(SyntaxTree::Index::ModuleDefinition)
      }.name.to_sym
      @var_refs = SyntaxTree.search(source, "VarRef")
      @commands = SyntaxTree.search(source, "Command")
    end

    def dependencies
      references + belongs + has_manies + has_ones
    end

    private

    def references
      consts.map(&:value).map(&:value).uniq.reject {|ref|
        # Reject consts
        ref.underscore.upcase == ref
      }.map(&:to_sym)
    end

    def consts
      @var_refs.select {|node|
        node.value.instance_of?(SyntaxTree::Const)
      }
    end

    def belongs
      pick_association_commands("belongs_to")
    end

    def has_manies
      pick_association_commands("has_many")
    end

    def has_ones
      pick_association_commands("has_one")
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
