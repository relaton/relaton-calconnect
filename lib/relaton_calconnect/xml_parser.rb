module RelatonCalconnect
  class XMLParser < RelatonBib::XMLParser
    class << self
      # override RelatonBib::BibliographicItem.bib_item method
      # @param item_hash [Hash]
      # @return [RelatonIsoBib::IsoBibliographicItem]
      def bib_item(item_hash)
        CcBibliographicItem.new item_hash
      end
    end
  end
end
