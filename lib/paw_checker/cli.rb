require 'thor'
require 'syntax_tree'
require 'paw_checker'
require 'gviz'

module PawChecker
  class CLI < Thor
    desc "structure [path]", "Run!"
    def structure(path)
      cls = ClassDefinition.parse(path)

      Graph do
        route cls.class_name => cls.dependencies
        save(:output, :png)
      end
    end
  end
end
