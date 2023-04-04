require 'thor'
require 'syntax_tree'
require 'paw_checker'
require 'gviz'

module PawChecker
  class CLI < Thor
    desc "structure [path]", "Run!"
    def structure(path)
      defs = ClassDefinition.parse(path)
      cls_set = Set.new(defs.map(&:class_name))
      Graph do
        defs.each do |cls|
          route cls.class_name => cls.dependencies.select {|d| cls_set.include?(d) }
        end
        save(:output, :png)
      end
    end

    desc "cluster [path]", "Calc cluster!"
    def cluster(path)
      defs = ClassDefinition.parse(path)
      cluster = Cluster.new(defs)
      puts cluster.modularity
      cluster.merge_simulation
    end
  end
end
