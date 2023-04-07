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
    method_options(limit: :numeric)
    def cluster(path)
      defs = ClassDefinition.parse(path)
      cluster = Cluster.new(defs)

      puts "Start marge simulation"
      loop do
        break unless cluster.merge!
        break if options.limit && cluster.modularity > options.limit
        puts "mod => #{cluster.modularity}"
      end
      puts "mod => #{cluster.modularity}"

      Graph do
        cluster.communities.each do |community|
          subgraph do
            community.definitions.each do |cls|
              route cls.class_name => cls.dependencies.select {|d| cluster.include?(d) }
            end
          end
        end
        save(:output, :png)
      end
    end
  end
end
