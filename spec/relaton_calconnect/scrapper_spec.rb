describe RelatonCalconnect::Scrapper do
  it "remove fetched" do
    hit = { "fetched" => "2019-12-12", "link" => [] }
    bib = double "bib", link: []
    expect(RelatonCalconnect::CcBibliographicItem).to receive(:from_hash)
      .with({ "link" => [] }).and_return bib
    described_class.parse_page hit
  end
end
