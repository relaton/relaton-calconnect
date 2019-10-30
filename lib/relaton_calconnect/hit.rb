module RelatonCalconnect
  class Hit < RelatonBib::Hit
    # @return [RelatonCalconnect::HitCollection]
    attr_reader :hit_collection

    # Parse page.
    # @return [RelatonCalconnect::CcBliographicItem]
    def fetch
      @fetch ||= Scrapper.parse_page @hit
    end
  end
end
