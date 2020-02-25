module RelatonCalconnect
  class Hit < RelatonBib::Hit
    # Parse page.
    # @return [RelatonCalconnect::CcBliographicItem]
    def fetch
      @fetch ||= Scrapper.parse_page @hit
    end
  end
end
