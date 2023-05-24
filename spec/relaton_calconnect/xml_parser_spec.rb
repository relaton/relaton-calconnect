RSpec.describe RelatonCalconnect::XMLParser do
  context "::fetch_editorialgroup" do
    it do
      doc = Nokogiri::XML <<~XML
        <bidata>
          <ext>
            <editorialgroup>
              <technical-committee type="TC" number="1">TC</technical-committee>
              <committee type="C">Committee</committee>
            </editorialgroup>
          </ext>
        </bidata>
      XML
      ext = doc.at "//ext"
      eg = described_class.fetch_editorialgroup ext
      expect(eg).to be_instance_of RelatonBib::EditorialGroup
      expect(eg.technical_committee).to be_instance_of Array
      expect(eg.technical_committee.size).to eq 2
      expect(eg.technical_committee.first).to be_instance_of RelatonCalconnect::TechnicalCommittee
      expect(eg.technical_committee.first.workgroup).to be_instance_of RelatonBib::WorkGroup
      expect(eg.technical_committee.first.workgroup.name).to eq "Committee"
      expect(eg.technical_committee.first.workgroup.type).to eq "C"
      expect(eg.technical_committee[1].workgroup.name).to eq "TC"
      expect(eg.technical_committee[1].workgroup.type).to eq "TC"
      expect(eg.technical_committee[1].workgroup.number).to eq 1
    end
  end
end
