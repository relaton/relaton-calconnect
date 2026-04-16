describe Relaton::Calconnect::Scraper do
  let(:errors) { {} }
  let(:scraper) { described_class.new(errors) }

  it "remove fetched" do
    hit = { "fetched" => "2019-12-12", "link" => [] }
    item = scraper.parse_page hit
    expect(item.fetched).to be_nil
  end

  it "parse page" do
    link = { "type" => "rxl", "content" => "csd/cc-0707.rxl" }
    hit = { "link" => [link] }
    bib = Relaton::Calconnect::ItemData.new source: [Relaton::Bib::Uri.new(type: "rxl", content: "csd/cc-0707.rxl")]
    expect(scraper).to receive(:fetch_bib_xml).with("csd/cc-0707.rxl").and_return bib
    # expect(scraper).to receive(:update_links).with(bib, hit[:link])
    expect(scraper.parse_page(hit)).to be bib
    expect(bib.source.first.content.to_s).to eq "https://standards.calconnect.org/csd/cc-0707.rxl"
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

      expect(scraper).to receive(:get_rxl).with(:url).and_return rxl1
      expect(scraper).to receive(:get_rxl).with("csd/cc-0707.rxl").and_return rxl2

      bib = scraper.send(:fetch_bib_xml, :url)

      expect(bib).to be_instance_of Relaton::Calconnect::ItemData
      expect(bib.docidentifier.first.content).to eq "CC/Adm0812-2008"
      expect(bib.source.size).to eq 3
      expect(bib.source[1].type).to eq "rxl"
    end
  end

  it "get_rxl" do
    resp = double "response", body: "body"
    expect(Faraday).to receive(:get).with("https://standards.calconnect.org/csd/cc-0707.rxl").and_return resp
    expect(Nokogiri).to receive(:XML).with("body").and_return "xml"
    expect(scraper.send(:get_rxl, "csd/cc-0707.rxl")).to eq "xml"
  end

  it "hash_to_item" do
    doc = {
      title: [
        { content: "Title", type: "main", language: ["en"], script: ["Latn"], format: "text/plain" }
      ],
      link: [{ content: "https://www.ribose.com" }],
      docid: { id: "CC/Adm0812-2008", type: "CC", primary: "true" },
      date: { type: "published", value: "2008-12-01" },
      contributor: [
        { organization: { name: [{ content: "CalConnect" }] }, role: [{ type: "publisher" }] },
        {
          person: {
            name: { completename: { content: "Eric York" } },
            affiliation: [
              {
                organization: {
                  name: [{ content: "Apple Inc." }],
                  contact: [
                    { address: { street: ["1 Infinite Loop"], city: "Cupertino", country: "USA", postcode: "95014" } }
                  ]
                }
              }
            ],
            contact: [{ email: "eyork@apple.com" }, { uri: "http://www.apple.com/" }]
          },
          role: [{ type: "author" }],
        }
      ],
      edition: { content: "1" },
      version: [{ revision_date: "2000-04-12" }],
      abstract: [{ content: "This is an abstract." }],
      docstatus: { stage: { value: "published" } },
      copyright: [{ owner: [{ name: { content: "CalConnect" } }] }],
      keyword: [{ content: "push" }],
      relation: [{ type: "derivedFrom", bibitem: { docid: { type: "CC", id: "CC/OldDoc-2000" } } }],
      editorialgroup: { name: "CALCONNECT" },
      ext: { doctype: { type: "directive", abbreviation: "D" } },
    }
    item = scraper.send(:hash_to_item, doc)
    expect(item).to be_instance_of Relaton::Calconnect::ItemData
    expect(item.title.first).to be_instance_of Relaton::Bib::Title
    expect(item.docidentifier.first).to be_instance_of Relaton::Bib::Docidentifier
    expect(item.date.first).to be_instance_of Relaton::Bib::Date
    expect(item.contributor.first).to be_instance_of Relaton::Bib::Contributor
    expect(item.edition).to be_instance_of Relaton::Bib::Edition
    expect(item.version.first).to be_instance_of Relaton::Bib::Version
    expect(item.status).to be_instance_of Relaton::Bib::Status
    expect(item.copyright.first).to be_instance_of Relaton::Bib::Copyright
    expect(item.relation.first).to be_instance_of Relaton::Bib::Relation
    expect(item.ext).to be_instance_of Relaton::Calconnect::Ext
    expect(item.ext.doctype).to be_instance_of Relaton::Calconnect::Doctype
    hash = YAML.load item.to_yaml
    expect(hash).to eq(
      "schema_version" => "v1.5.6",
      "id" => "CCAdm08122008",
      "title" => [{ "content" => "Title", "type" => "main", "language" => "en", "script" => "Latn" }],
      "source" => [{ "content" => "https://www.ribose.com", "type" => "src" }],
      "docidentifier" => [{ "content" => "CC/Adm0812-2008", "type" => "CC", "primary" => true }],
      "date" => [{ "at" => "2008-12-01", "type" => "published" }],
      "contributor" => [
        { "organization" => { "name" => [{ "content" => "CalConnect" }] }, "role" => [{ "type" => "publisher"}] },
        {
          "person" => {
            "name" => { "completename" => { "content" => "Eric York" } },
            "affiliation" => [
              {
                "organization" => {
                  "address" => [{
                    "street" => ["1 Infinite Loop"],
                    "city" => "Cupertino",
                    "country" => "USA",
                    "postcode" => "95014"
                  }],
                  "name" => [{ "content" => "Apple Inc." }]
                }
              }
            ],
            "email" => ["eyork@apple.com"],
            "uri" => [{ "content"=>"http://www.apple.com/" }]
          },
          "role" => [{ "type"=>"author" }]
        },
        {
          "organization" => {
            "name" => [{ "content" => "CalConnect" }],
            "subdivision" => [{ "name" => [{ "content" => "CALCONNECT" }], "type" => "technical-committee" }]
          },
          "role" => [{ "description" => [{ "content" => "committee" }], "type" => "author"}]
        }
      ],
      "edition" => { "number" => "1" },
      "version" => [{ "revision_date" => "2000-04-12" }],
      "abstract" => [{ "content" => "This is an abstract." }],
      "status" => { "stage" => { "content" => "published" } },
      "copyright" => [{ "owner" => [{ "organization" => { "name" => [{ "content" => "CalConnect" }] } }] }],
      "keyword" => [{ "vocab" => { "content" => "push" } }],
      "relation" => [
        {
          "bibitem" => { "docidentifier" => [{ "content" => "CC/OldDoc-2000", "primary" => true, "type" => "CC" }] },
          "type" => "derivedFrom"
        }
      ],
      "ext" => {
        "doctype" => { "content" => "directive", "abbreviation" => "D" },
        "flavor" => "calconnect",
        "schema_version" => "v1.1.2"
      },
    )
  end

  it "update_links" do
    links = [
      { type: "src", content: "csd/cc-0707.rxl" },
      { type: "xml", content: "csd/cc-0707.xml" },
    ]
    xml_link = Relaton::Bib::Uri.new(type: "xml", content: "csd/cc-0707.xml")
    bib = Relaton::Calconnect::ItemData.new source: [xml_link]
    scraper.send(:update_links, bib, links)
    expect(bib.source.size).to eq 2
    expect(bib.source.last).to be_instance_of Relaton::Bib::Uri
    expect(bib.source.last.type).to eq "src"
    expect(bib.source.last.content.to_s).to eq "csd/cc-0707.rxl"
  end
end
