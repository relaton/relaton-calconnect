require "relaton/processor"

module RelatonCalconnect
  class Processor < Relaton::Processor
    attr_reader :idtype

    def initialize
      @short = :relaton_calconnect
      @prefix = "CC"
      @defaultprefix = %r{^CC\s}
      @idtype = "CC"
    end

    # @param code [String]
    # @param date [String, NilClass] year
    # @param opts [Hash]
    # @return [RelatonCalconnect::CcBibliographicItem]
    def get(code, date, opts)
      ::RelatonCalconnect::CcBibliography.get(code, date, opts)
    end

    # @param xml [String]
    # @return [RelatonCalconnect::CcBibliographicItem]
    def from_xml(xml)
      ::RelatonCalconnect::XMLParser.from_xml xml
    end

    # @param hash [Hash]
    # @return [RelatonIsoBib::CcBibliographicItem]
    def hash_to_bib(hash)
      item_hash = ::RelatonCalconnect::HashConverter.hash_to_bib(hash)
      ::RelatonCalconnect::CcBibliographicItem.new item_hash
    end
  end
end
