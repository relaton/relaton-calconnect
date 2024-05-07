module RelatonCalconnect
  module XMLParser
    include RelatonBib::Parser::XML
    extend self
    # override RelatonBib::BibliographicItem.bib_item method
    # @param item_hash [Hash]
    # @return [RelatonCalconnect::CcBibliographicItem]
    def bib_item(item_hash)
      CcBibliographicItem.new(**item_hash)
    end

    # @param ext [Nokogiri::XML::Element]
    # @return [RelatonBib::EditorialGroup, nil]
    def fetch_editorialgroup(ext)
      return unless ext && (eg = ext.at "editorialgroup")

      eg = eg.xpath("committee", "technical-committee").map do |tc|
        wg = RelatonBib::WorkGroup.new(name: tc.text, number: tc[:number]&.to_i,
                                        type: tc[:type])
        TechnicalCommittee.new wg
      end
      RelatonBib::EditorialGroup.new eg if eg.any?
    end
  end
end
