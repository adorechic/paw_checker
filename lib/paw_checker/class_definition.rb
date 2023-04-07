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
      @dependencies ||= (references + belongs + has_manies + has_ones).uniq
    end

    private

    def references
      consts.map(&:value).map(&:value).uniq.reject {|ref|
        # Reject consts
        ref.underscore.upcase == ref ||
          # Reject self
          ref.to_sym == class_name
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
      filtered_command_first_args(type: type).map {|arg|
        arg.child_nodes.first.value.classify.to_sym
      }
    end

    def filtered_command_first_args(type:)
      filtered_commands(type: type).map {|method, args|
        args.child_nodes.first
      }.select {|first_arg|
        # This code ignores strings
        # e.g. has_many "hoge_#{pattern}"
        first_arg.instance_of?(SyntaxTree::SymbolLiteral)
      }
    end

    def filtered_commands(type:)
      @commands.map {|node|
        node.child_nodes
      }.select {|method, args|
        method.value == type
      }
    end
  end
end
