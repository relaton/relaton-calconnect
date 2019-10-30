RSpec.describe RelatonCalconnect do
  it "has a version number" do
    expect(RelatonCalconnect::VERSION).not_to be nil
  end

  context "search" do
    it "hits" do
      VCR.use_cassette "data", match_requests_on: [:path] do
        VCR.use_cassette "cc_dir_10005_2019", match_requests_on: [:path] do
          hit_collection = RelatonCalconnect::CcBibliography.search("CC/DIR 10005:2019")
          expect(hit_collection.fetched).to be false
          expect(hit_collection.fetch).to be_instance_of RelatonCalconnect::HitCollection
          expect(hit_collection.fetched).to be true
          expect(hit_collection.first).to be_instance_of RelatonCalconnect::Hit
        end
      end
    end

    it "raises RequestError" do
      req = double
      expect(req).to receive(:get).and_raise Faraday::Error::ConnectionFailed.new("Connection error")
      expect(Faraday).to receive(:new).and_return req
      expect(File).to receive(:exist?).and_return(true).twice
      expect(File).to receive(:ctime).and_return Time.now - 3600 * 24
      expect do
        RelatonCalconnect::CcBibliography.search("CC/DIR 10005:2019")
      end.to raise_error RelatonBib::RequestError
    end
  end

  context "gets" do
    it "reference" do
      VCR.use_cassette "data", match_requests_on: [:path] do
        VCR.use_cassette "cc_dir_10005_2019", match_requests_on: [:path] do
          item = RelatonCalconnect::CcBibliography.get "CC/DIR 10005"
          expect(item).to be_instance_of RelatonCalconnect::CcBibliographicItem
          expect(item.docidentifier.first.id).to eq "CC/DIR 10005:2019"
        end
      end
    end

    it "reference with year" do
      VCR.use_cassette "data", match_requests_on: [:path] do
        VCR.use_cassette "cc_dir_10005_2019", match_requests_on: [:path] do
          item = RelatonCalconnect::CcBibliography.get "CC/DIR 10005:2019"
          file = "spec/fixtures/cc_dir_10005_2019.xml"
          xml = item.to_xml bibdata: true
          File.write file, xml, encoding: "UTF-8" unless File.exist? file
          expect(xml).to be_equivalent_to File.read(file, encoding: "UTF-8")
        end
      end
    end

    it "code and year" do
      VCR.use_cassette "data", match_requests_on: [:path] do
        VCR.use_cassette "cc_dir_10005_2019", match_requests_on: [:path] do
          item = RelatonCalconnect::CcBibliography.get "CC/DIR 10005", "2019"
          file = "spec/fixtures/cc_r_1104_2018.xml"
          xml = item.to_xml bibdata: true
          File.write file, xml, encoding: "UTF-8" unless File.exist? file
          expect(xml).to be_equivalent_to File.read file, encoding: "UTF-8"
        end
      end
    end

    it "incorrect year" do
      VCR.use_cassette "data", match_requests_on: [:path] do
        VCR.use_cassette "cc_dir_10005_2019", match_requests_on: [:path] do
          expect do
            RelatonCalconnect::CcBibliography.get "CC/DIR 10005", "2011"
          end.to output(%r{no match found online for CC/DIR 10005 year 2011}).to_stderr
        end
      end
    end

    it "incorrect code" do
      VCR.use_cassette "data", match_requests_on: [:path] do
        expect do
          RelatonCalconnect::CcBibliography.get "123456"
        end.to output(/no match found online for 123456/).to_stderr
      end
    end
  end
end
