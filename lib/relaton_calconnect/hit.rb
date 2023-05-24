module RelatonCalconnect
  class Hit < RelatonBib::Hit
    # Parse page.
    # @return [RelatonCalconnect::CcBliographicItem]
    def fetch
      # @fetch ||= Scrapper.parse_page @hit
      @fetch ||= begin
        url = "#{HitCollection::GHURL}#{@hit[:file]}"
        resp = Faraday.get url
        CcBibliographicItem.from_hash YAML.safe_load(resp.body)
      end
    end
  end
end
