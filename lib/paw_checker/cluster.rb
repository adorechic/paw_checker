module PawChecker
  class Cluster
    def initialize(definitions)
      @definitions = definitions
      @communities = @definitions.map do |definition|
        Community.new(self, [definition])
      end
    end

    def total_edge_count
      @total_edge_count ||= @definitions.sum {|d| d.dependencies.size }
    end

    def modularity
      @communities.sum do |community|
        community.internal_edge_score - community.external_edge_score ** 2
      end
    end
  end
end
