module PawChecker
  class ClassDefinition
    class << self
      def parse(path)
        source = SyntaxTree.read(path)
        idx = SyntaxTree.index(source)
        cls = idx.find {|i|
          i.instance_of?(SyntaxTree::Index::ClassDefinition)
        }
        puts "class name"
        puts cls.name

        var_refs = SyntaxTree.search(source, "VarRef")
        consts = var_refs.select {|node|
          node.value.instance_of?(SyntaxTree::Const)
        }
        puts "#dependency"
        p consts.map(&:value).map(&:value).uniq

        commands = SyntaxTree.search(source, "Command")
        cls = ClassDefinition.new(commands)
        cls.pretty_print
      end
    end

    def initialize(commands)
      @commands = commands
    end

    def pretty_print
      puts "#belongs_to"
      p belongs

      puts "#has_many"
      p has_manies

      puts "#has_one"
      p has_ones
    end

    private

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
