module PawChecker
  class Community
    attr_reader :nodes

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

    private

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
