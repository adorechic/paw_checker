module PawChecker
  class Cluster
    attr_reader :communities

    def initialize(definitions)
      @definitions = definitions
      @nodes = @definitions.map(&:class_name)
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

    def include?(node)
      @nodes.include?(node)
    end

    def merge!
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
      if max_score > 0
        max_from.merge!(max_to)
        true
      else
        false
      end
    end
  end
end
