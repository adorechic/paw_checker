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

    def merge_simulation
      max_from = nil
      max_to = nil
      max_score = -1

      @communities.combination(2).each do |from, to|
        score = from.simulate_merged_score_change(to)
        if score > max_score
          max_from = from
          max_to = to
          max_score = score
        end
      end
      p [max_from.nodes, max_to.nodes, max_score]
    end
  end
end
