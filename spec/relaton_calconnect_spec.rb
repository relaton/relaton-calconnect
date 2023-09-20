require "jing"

RSpec.describe RelatonCalconnect do
  before { RelatonCalconnect.instance_variable_set :@configuration, nil }

  it "has a version number" do
    expect(RelatonCalconnect::VERSION).not_to be nil
  end

  it "returs grammar hash" do
    hash = RelatonCalconnect.grammar_hash
    expect(hash).to be_instance_of String
    expect(hash.size).to eq 32
  end

  context "search" do
    it "hits" do
      VCR.use_cassette "cc_dir_10005_2019", match_requests_on: [:path] do
        hc = RelatonCalconnect::CcBibliography.search("CC/DIR 10005:2019")
        expect(hc.fetched).to be false
        expect(hc.fetch).to be_instance_of RelatonCalconnect::HitCollection
        expect(hc.fetched).to be true
        expect(hc.first).to be_instance_of RelatonCalconnect::Hit
      end
    end

    it "raises RequestError" do
      expect(RelatonCalconnect::HitCollection).to receive(:new)
        .and_raise Faraday::ConnectionFailed.new("Connection error")
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
            .sub(/(?<=<fetched>)\d{4}-\d{2}-\d{2}/, Date.today.to_s)
          schema = Jing.new "grammars/relaton-cc-compile.rng"
          errors = schema.validate file
          expect(errors).to eq []
        end
      end
    end

    it "code and year" do
      VCR.use_cassette "data", match_requests_on: [:path] do
        VCR.use_cassette "cc_dir_10005_2019", match_requests_on: [:path] do
          item = RelatonCalconnect::CcBibliography.get "CC/DIR 10005", "2019"
          file = "spec/fixtures/cc_dir_10005_2019.xml"
          xml = item.to_xml bibdata: true
          File.write file, xml, encoding: "UTF-8" unless File.exist? file
          expect(xml).to be_equivalent_to File.read(file, encoding: "UTF-8")
            .sub(/(?<=<fetched>)\d{4}-\d{2}-\d{2}/, Date.today.to_s)
          schema = Jing.new "grammars/relaton-cc-compile.rng"
          errors = schema.validate file
          expect(errors).to eq []
        end
      end
    end

    it "incorrect year" do
      VCR.use_cassette "data", match_requests_on: [:path] do
        VCR.use_cassette "cc_dir_10005_2019", match_requests_on: [:path] do
          expect do
            RelatonCalconnect::CcBibliography.get "CC/DIR 10005", "2011"
          end.to output(%r{no match found online for `CC/DIR 10005` year `2011`}).to_stderr
        end
      end
    end

    it "not found" do
      VCR.use_cassette "data", match_requests_on: [:path] do
        expect do
          RelatonCalconnect::CcBibliography.get "CC/DIR 123456"
        end.to output(/no match found online for CC\/DIR 123456/).to_stderr
      end
    end
  end
end
