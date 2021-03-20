module RelatonCalconnect
  class CcBibliographicItem < RelatonBib::BibliographicItem
    TYPES = %w[
      directive guide specification standard report administrative amendment
      technical\ corrigendum advisory
    ].freeze

    # @param hash [Hash]
    # @return [RelatonIsoBib::CcBibliographicItem]
    def self.from_hash(hash)
      item_hash = ::RelatonCalconnect::HashConverter.hash_to_bib(hash)
      new **item_hash
    end
  end
end
