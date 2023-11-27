module RelatonCalconnect
  class CcBibliographicItem < RelatonBib::BibliographicItem
    #
    # Fetch flavor schema version
    #
    # @return [String] flavor schema version
    #
    def ext_schema
      @ext_schema ||= schema_versions["relaton-model-cc"]
    end

    # @param hash [Hash]
    # @return [RelatonIsoBib::CcBibliographicItem]
    def self.from_hash(hash)
      item_hash = ::RelatonCalconnect::HashConverter.hash_to_bib(hash)
      new(**item_hash)
    end
  end
end
