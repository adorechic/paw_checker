require 'thor'
require 'syntax_tree'
require 'paw_checker'
require 'gviz'

module PawChecker
  class CLI < Thor
    desc "structure [path]", "Run!"
    def structure(path)
      defs = if File.directory?(path)
               Dir.glob("#{path}/app/models/**/*.rb").map do |path|
                 ClassDefinition.parse(path)
               end
             else
               [ClassDefinition.parse(path)]
             end
      clsSet = Set.new(defs.map(&:class_name))
      Graph do
        defs.each do |cls|
          route cls.class_name => cls.dependencies.select {|d| clsSet.include?(d) }
        end
        save(:output, :png)
      end
    end
  end
end
