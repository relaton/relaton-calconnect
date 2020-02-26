module RelatonCalconnect
  class XMLParser < RelatonIsoBib::XMLParser
    class << self
      def from_xml(xml)
        doc = Nokogiri::XML xml
        doc.remove_namespaces!
        cctitem = doc.at("/bibitem|/bibdata")
        if cctitem
          CcBibliographicItem.new(item_data(cctitem))
        else
          warn "[relato-calconnect] can't find bibitem or bibdata element in the XML"
        end
      end
    end
  end
end
