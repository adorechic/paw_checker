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
      }.name
      @var_refs = SyntaxTree.search(source, "VarRef")
      @commands = SyntaxTree.search(source, "Command")
    end

    def pretty_print
      puts "class name"
      puts @class_name

      puts "#dependency"
      p consts.map(&:value).map(&:value).uniq

      puts "#belongs_to"
      p belongs

      puts "#has_many"
      p has_manies

      puts "#has_one"
      p has_ones
    end

    private

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
        node.child_nodes[1].child_nodes.first.child_nodes.first.value
      }
    end
  end
end
