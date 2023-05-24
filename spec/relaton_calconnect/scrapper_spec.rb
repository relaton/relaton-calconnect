describe RelatonCalconnect::Scrapper do
  it "remove fetched" do
    hit = { "fetched" => "2019-12-12", "link" => [] }
    bib = double "bib", link: []
    expect(RelatonCalconnect::CcBibliographicItem).to receive(:from_hash)
      .with({ "link" => [] }).and_return bib
    described_class.parse_page hit
  end

  it "parse page" do
    link = { "type" => "rxl", "content" => "csd/cc-0707.rxl" }
    hit = { "link" => [link] }
    bib = double "bib", link: [RelatonBib::TypedUri.new(type: "rxl", content: "csd/cc-0707.rxl")]
    expect(described_class).to receive(:fetch_bib_xml).with("csd/cc-0707.rxl").and_return bib
    expect(described_class).to receive(:update_links).with(bib, hit["link"])
    expect(described_class.parse_page(hit)).to be bib
    expect(bib.link.first.content.to_s).to eq "https://standards.calconnect.org/csd/cc-0707.rxl"
  end

  context "fetch_bib_xml" do
    it "merge URIs from 2 docs" do
      rxl1 = Nokogiri::XML <<~XML
        <bibdata type="standard">
          <uri type="rxl">csd/cc-0707.rxl</uri>
          <uri type="xml">csd/cc-0707.xml</url>
        </bibdata>
      XML

      rxl2 = Nokogiri::XML <<~XML
        <bibdata type="standard">
          <uri type="doc">csd/cc-0707.doc</uri>
          <docidentifier type="CC">CC/Adm0812-2008</docidentifier>
        </bibdata>
      XML

      expect(described_class).to receive(:get_rxl).with(:url).and_return rxl1
      expect(described_class).to receive(:get_rxl).with("csd/cc-0707.rxl").and_return rxl2

      bib = described_class.send(:fetch_bib_xml, :url)

      expect(bib).to be_instance_of RelatonCalconnect::CcBibliographicItem
      expect(bib.docidentifier.first.id).to eq "CC/Adm0812-2008"
      expect(bib.link).to be_instance_of Array
      expect(bib.link.size).to eq 3
      expect(bib.link[1].type).to eq "rxl"
    end
  end

  it "get_rxl" do
    resp = double "response", body: "body"
    expect(Faraday).to receive(:get).with("https://standards.calconnect.org/csd/cc-0707.rxl").and_return resp
    expect(Nokogiri).to receive(:XML).with("body").and_return "xml"
    expect(described_class.send(:get_rxl, "csd/cc-0707.rxl")).to eq "xml"
  end

  it "doc_to_hash" do
    doc = {
      "docid" => { "id" => "CC/Adm0812-2008", "type" => "CC" },
      "editorialgroup" => { "technical_committee" => { "name" => "IOPTEST" } },
    }
    described_class.send(:doc_to_hash, doc)
    expect(doc).to eq(
      "docid" => { "id" => "CC/Adm0812-2008", "type" => "CC", "primary" => true },
      "editorialgroup" => { "name" => "IOPTEST" },
    )
  end

  it "update_links" do
    links = [
      { "type" => "src", "content" => "csd/cc-0707.rxl" },
      { "type" => "xml", "content" => "csd/cc-0707.xml" },
    ]
    bib = double("bib", link: [])
    expect(bib).to receive(:url).with("src").and_return nil
    expect(bib).to receive(:url).with("xml").and_return "csd/cc-0707.xml"
    described_class.send(:update_links, bib, links)
    expect(bib.link.size).to eq 1
    expect(bib.link.first).to be_instance_of RelatonBib::TypedUri
    expect(bib.link.first.type).to eq "src"
    expect(bib.link.first.content.to_s).to eq "csd/cc-0707.rxl"
  end
end
