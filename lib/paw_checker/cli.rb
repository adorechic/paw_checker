require 'thor'
require 'syntax_tree'
require 'paw_checker'

module PawChecker
  class CLI < Thor
    desc "structure [path]", "Run!"
    def structure(path)
      ClassDefinition.parse(path)
    end
  end
end
