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

        cls = ClassDefinition.new(commands)
        cls.pretty_print
      end
    end

    def initialize(commands)
      @commands = commands
    end

    def pretty_print
      has_ones = @commands.select {|node|
        node.child_nodes.first.value == "has_one"
      }.map {|node|
        node.child_nodes[1].child_nodes.first.child_nodes.first.value
      }
      puts "#has_one"
      p has_ones
    end

  end
end
