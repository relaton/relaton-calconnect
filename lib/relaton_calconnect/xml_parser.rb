module RelatonCalconnect
  class XMLParser < RelatonIsoBib::XMLParser
    class << self
      def from_xml(xml)
        doc = Nokogiri::XML xml
        doc.remove_namespaces!
        cctitem = doc.at("/bibitem|/bibdata")
        CcBibliographicItem.new(item_data(cctitem))
      end
    end
  end
end
