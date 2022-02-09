module RelatonCalconnect
  module Scrapper
    DOMAIN = "https://standards.calconnect.org/".freeze
    SCHEME, HOST = DOMAIN.split(%r{:?/?/})
    # DOMAIN = "http://127.0.0.1:4000/".freeze

    class << self
      # papam hit [Hash]
      # @return [RelatonOgc::OrcBibliographicItem]
      def parse_page(hit) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        links = array(hit["link"])
        link = links.detect { |l| l["type"] == "rxl" }
        if link
          bib = fetch_bib_xml link["content"]
          update_links bib, links
          # XMLParser.from_xml bib_xml
        else
          bib = RelatonCalconnect::CcBibliographicItem.from_hash doc_to_hash hit
        end
        bib.link.each do |l|
          l.content.merge!(scheme: SCHEME, host: HOST) unless l.content.host
        end
        bib
      end

      private

      # @param url [String]
      # @return [String] XML
      def fetch_bib_xml(url) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        rxl = get_rxl url
        uri_rxl = rxl.at("uri[@type='rxl']")
        if uri_rxl
          uri_xml = rxl.xpath("//uri").to_xml
          rxl = get_rxl uri_rxl.text
          docid = rxl.at "//docidentifier"
          docid.add_previous_sibling uri_xml
        end
        xml = rxl.to_xml.gsub!(%r{(</?)technical-committee(>)}, '\1committee\2')
          .gsub(%r{type="(?:csd|CC)"(?=>)}i, '\0 primary="true"')
        RelatonCalconnect::XMLParser.from_xml xml
      end

      # @param path [String]
      # @return [Nokogiri::XML::Document]
      def get_rxl(path)
        resp = Faraday.get DOMAIN + path
        Nokogiri::XML resp.body
      end

      #
      # Fix editorial group
      #
      # @param [Hash] doc
      #
      # @return [Hash]
      #
      def doc_to_hash(doc)
        array(doc["editorialgroup"]).each do |eg|
          tc = eg.delete("technical_committee")
          eg.merge!(tc) if tc
        end
        dtps = %w[CC CSD]
        array(doc["docid"]).detect { |id| dtps.include? id["type"].upcase }["primary"] = true
        doc
      end

      def update_links(bib, links)
        links.each do |l|
          tu = l.transform_keys(&:to_sym)
          bib.link << RelatonBib::TypedUri.new(**tu) unless bib.url(l["type"])
        end
        bib
      end

      #
      # Wrap into Array if not Array
      #
      # @param [Array, Hash, String, nil] content
      #
      # @return [Array<Hash, String>]
      #
      def array(content)
        case content
        when Array then content
        when nil then []
        else [content]
        end
      end
    end
  end
end
