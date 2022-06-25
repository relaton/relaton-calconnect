require "relaton/processor"

module RelatonCalconnect
  class Processor < Relaton::Processor
    attr_reader :idtype

    def initialize # rubocop:disable Lint/MissingSuper
      @short = :relaton_calconnect
      @prefix = "CC"
      @defaultprefix = %r{^CC(?!\w)}
      @idtype = "CC"
      @datasets = %w[calconnect-org]
    end

    # @param code [String]
    # @param date [String, NilClass] year
    # @param opts [Hash]
    # @return [RelatonCalconnect::CcBibliographicItem]
    def get(code, date, opts)
      ::RelatonCalconnect::CcBibliography.get(code, date, opts)
    end

    #
    # Fetch all the documents from a source
    #
    # @param [String] _source source name
    # @param [Hash] opts
    # @option opts [String] :output directory to output documents
    # @option opts [String] :format
    #
    def fetch_data(_source, opts)
      DataFetcher.fetch(**opts)
    end

    # @param xml [String]
    # @return [RelatonCalconnect::CcBibliographicItem]
    def from_xml(xml)
      ::RelatonCalconnect::XMLParser.from_xml xml
    end

    # @param hash [Hash]
    # @return [RelatonIsoBib::CcBibliographicItem]
    def hash_to_bib(hash)
      ::RelatonCalconnect::CcBibliographicItem.from_hash hash
    end

    # Returns hash of XML grammar
    # @return [String]
    def grammar_hash
      @grammar_hash ||= ::RelatonCalconnect.grammar_hash
    end
  end
end
