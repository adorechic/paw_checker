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

      Graph do
        defs.each do |cls|
          route cls.class_name => cls.dependencies
        end
        save(:output, :png)
      end
    end
  end
end
