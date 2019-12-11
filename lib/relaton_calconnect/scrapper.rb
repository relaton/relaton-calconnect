module RelatonCalconnect
  module Scrapper
    DOMAIN = "https://standards.calconnect.org/".freeze
    # DOMAIN = "http://127.0.0.1:4000/".freeze

    class << self
      # papam hit [Hash]
      # @return [RelatonOgc::OrcBibliographicItem]
      def parse_page(hit)
        link = hit["link"].detect { |l| l["type"] == "rxl" }
        if link
          bib_xml = fetch_bib_xml link["content"]
          XMLParser.from_xml bib_xml
        end
      end

      private

      # @param url [String]
      # @return [String] XML
      def fetch_bib_xml(url)
        rxl = get_rxl url
        uri_rxl = rxl.at("uri[@type='rxl']")
        return rxl.to_xml unless uri_rxl

        uri_xml = rxl.xpath("//uri").to_xml
        rxl = get_rxl uri_rxl.text
        docid = rxl.at "//docidentifier"
        docid.add_previous_sibling uri_xml
        rxl.to_xml
      end

      # @param path [String]
      # @return [Nokogiri::XML::Document]
      def get_rxl(path)
        resp = Faraday.get DOMAIN + path
        Nokogiri::XML resp.body
      end
    end
  end
end
