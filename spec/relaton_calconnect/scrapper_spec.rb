describe RelatonCalconnect::Scrapper do
  it "remove fetched" do
    hit = { "fetched" => "2019-12-12", "link" => [] }
    bib = double "bib", link: []
    expect(RelatonCalconnect::CcBibliographicItem).to receive(:from_hash)
      .with({ "link" => [] }).and_return bib
    described_class.parse_page hit
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
end
