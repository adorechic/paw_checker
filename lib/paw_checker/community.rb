module PawChecker
  class Community
    attr_reader :nodes, :definitions

    def initialize(cluster, definitions)
      @cluster = cluster
      @definitions = definitions
      @nodes = Set.new(@definitions.map(&:class_name))
    end

    def internal_edge_score
      internal_edge_count / @cluster.total_edge_count.to_f
    end

    def external_edge_score
      external_edge_count / @cluster.total_edge_count.to_f
    end

    def community_edge_score(community)
      community_edge_count(community) / @cluster.total_edge_count.to_f
    end

    def simulate_merged_score_change(community)
      2 * (community_edge_score(community) - external_edge_score * community.external_edge_score)
    end

    def merge!(community)
      @definitions = @definitions + community.definitions
      @nodes = @nodes + community.nodes
      @cluster.communities.delete(community)
    end

    private

    def community_edge_count(community)
      @definitions.sum do |definition|
        definition.dependencies.select { |dependency|
          community.nodes.include?(dependency)
        }.size
      end
    end

    def external_edge_count
      @definitions.sum do |definition|
        definition.dependencies.select { |dependency|
          !@nodes.include?(dependency)
        }.size
      end
    end

    def internal_edge_count
      @definitions.sum do |definition|
        definition.dependencies.select { |dependency|
          @nodes.include?(dependency)
        }.size
      end
    end
  end
end
